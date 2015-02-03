Puppet::Type.type(:rpmkey).provide(:rpm) do

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

  def create
    raise Puppet::Error, "Cannot add key without a source" unless @resource[:source]
    rpm('--import', @resource[:source])
  end

  def exists?
    get(:ensure) != :absent
  end

  def destroy
    rpm('-e', '--allmatches', "gpg-pubkey-#{@resource[:name].downcase}")
  end

end
