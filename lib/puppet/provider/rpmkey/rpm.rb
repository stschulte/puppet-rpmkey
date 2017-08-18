require 'uri'
require 'puppet/network/http/compression'

if Puppet::PUPPETVERSION.split('.').first.to_i < 4
  require 'puppet/network/http/api/v1'
else
  # indirected_routes is only available in puppet >= 4
  require 'puppet/network/http/api/indirected_routes'
end

Puppet::Type.type(:rpmkey).provide(:rpm) do
  include Puppet::Network::HTTP::Compression.module

  commands :rpm => 'rpm'

  def self.instances
    keys = []

    begin
      rpm_query = rpm('-q','gpg-pubkey')
    rescue Puppet::ExecutionFailure
      return []
    end

    rpm_query.each_line do |line|
      line.chomp!
      if match = /^gpg-pubkey-([0-9a-f]*)-[0-9a-f]*/.match(line)
        keys << new(:name => match.captures[0].upcase, :ensure => :present)
      else
        warning "Unexpected rpm output #{line.inspect}. Ignoring this line."
      end
    end
    keys
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def metadata(source)
    metadata = nil
    environment = resource.catalog.respond_to?(:environment_instance) ? resource.catalog.environment_instance : resource.catalog.environment
    begin
      if metadata = Puppet::FileServing::Metadata.indirection.find(source, :environment => environment, :links => :follow)
        metadata.source = source
      end
    rescue => detail
      self.fail Puppet::Error, "Could not retrieve file metadata for #{source}: #{detail}", detail
    end
    self.fail "Could not retrieve information from environment #{resource.catalog.environment} source #{source}" unless metadata
    metadata
  end

  def path(source)
    uri = URI.parse(URI.escape(source))
    case uri.scheme
    when 'file'
      # no need to download a local file. Just use the filename
      uri_to_path(uri)
    when 'puppet'
      puppet_source_to_path(source)
    else
      # we don't know how to handle other types (e.g. http or https)
      # so we trust rpm how to handle these
      source
    end
  end

  def puppet_source_to_path(source)
    environment = resource.catalog.respond_to?(:environment_instance) ? resource.catalog.environment_instance : resource.catalog.environment

    metadata = metadata(source)

    # if the source is a puppet url we have to check if we can
    # point to a local file (running puppet apply) or if we have to
    # download the file first (when running puppet agent)
    if Puppet[:default_file_terminus] == :file_server
      if file = Puppet::FileServing::Content.indirection.find(metadata.source, :environment => environment, :links => :follow)
        file.path
      else
        self.fail "Could not find any content at #{metadata.source}"
      end
    else
      tmpfile = Tempfile.new('rpmkey')
      request = Puppet::Indirector::Request.new(:file_content, :find, metadata.source,  nil, :environment => environment)
      request.do_request(:fileserver) do |req|

        connection = Puppet::Network::HttpPool.http_instance(req.server, req.port)
        format = Puppet::FileServing::Content.supported_formats.include?(:binary) ? 'binary' : 'raw'
        uri = if defined?(Puppet::Network::HTTP::API::IndirectedRoutes)
          Puppet::Network::HTTP::API::IndirectedRoutes.request_to_uri(req)
        else
          Puppet::Network::HTTP::API::V1.indirection2uri(req)
        end

        connection.request_get(uri, add_accept_encoding({"Accept" => format})) do |response|
          if response.code =~ /^2/
            uncompress(response) do |uncompressor|
              response.read_body do |chunk|
                tmpfile.print uncompressor.uncompress(chunk)
              end
            end
          else
            # Raise the http error if we didn't get a 'success' of some kind.
            message = "Error #{response.code} on SERVER: #{(response.body||'').empty? ? response.message : uncompress_body(response)}"
            raise Net::HTTPError.new(message, response)
          end
        end
      end
      tmpfile.close
      tmpfile.path
    end
  end

  def create
    raise Puppet::Error, "Cannot add key without a source" unless @resource[:source]
    rpm '--import', path(@resource[:source])
  end

  def exists?
    get(:ensure) != :absent
  end

  def destroy
    rpm('-e', '--allmatches', "gpg-pubkey-#{@resource[:name].downcase}")
  end

end
