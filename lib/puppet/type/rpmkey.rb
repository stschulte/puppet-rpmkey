Puppet::Type.newtype(:rpmkey) do

  @doc = "Define public GPG keys that should be part of the rpm
    keyring."

  newparam(:name) do
    desc "The name of the key. This is the keyID (in hex) in
      uppercase."

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
