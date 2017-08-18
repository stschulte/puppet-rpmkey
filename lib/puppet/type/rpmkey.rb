require 'uri'

Puppet::Type.newtype(:rpmkey) do

  @doc = "Define public GPG keys that should be part of the rpm
    keyring.

    **Autorequires:** If puppet is managing the keyfile as a `file` resource,
    the `rpmkey` resource will autorequire that file"

  newparam(:name) do
    desc "The `name` of the `rpmkey` resource has to be the keyID (in hex)
      of the gpg key in uppercase.  If you have the public key available as a
      file but you are unsure of the correct keyID, use `gpg` to extract the
      keyID.  For example, to find the keyID used by EPEL 7:

          $ gpg ./RPM-GPG-KEY-EPEL-7
          pub  4096R/352C64E5 2013-12-16 Fedora EPEL (7) <epel@fedoraproject.org>

      in this case, `352C64E5` would be the correct name."

    isnamevar

    validate do |value|
      raise Puppet::Error, "Name must not be empty" if value.empty?
      unless value =~ /^[0-9A-F]*$/
        raise Puppet::Error, "Invalid key #{value}. The key has be a valid keyID (in hex) in uppercase."
      end
    end
  end

  ensurable

  newparam(:source) do
    desc "The source of the public key. This can be a local file or
        any URL that `rpm` supports (e.g. `http`). You can also specify
        a `puppet://` URL in which case the keyfile will be downloaded
        from the puppet master prior to importing it."

    validate do |source|
      # the value must be either a filename or a valid URL
      unless Puppet::Util.absolute_path?(source)
        begin
          uri = URI.parse(URI.escape(source))
        rescue => detail
          raise Puppet::Error, "Could not understand source #{source}: #{detail}"
        end

        raise Puppet::Error, "Cannot use relative URLs '#{source}'" unless uri.absolute?
        raise Puppet::Error, "Cannot use opaque URLs '#{source}'" unless uri.hierarchical?
      end
    end

    SEPARATOR_REGEX = [Regexp.escape(File::SEPARATOR.to_s), Regexp.escape(File::ALT_SEPARATOR.to_s)].join

    # make sure we always pass a valid URI to the provider
    munge do |source|
      source = source.sub(/[#{SEPARATOR_REGEX}]+$/, '')
      if Puppet::Util.absolute_path?(source)
        URI.unescape(Puppet::Util.path_to_uri(source).to_s)
      else
        source
      end
    end
  end

  autorequire(:file) do
    if source = self[:source] and uri = URI.parse(URI.escape(source)) and uri.scheme == 'file'
      uri_to_path(uri)
    end
  end

end
