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
    desc "The source of the public key if the key is not already imported."
  end

  autorequire(:file) do
    self[:source] if self[:source] =~ /^\//
  end

end
