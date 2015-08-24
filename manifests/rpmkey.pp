# Manage rpm keys

define rpmkey::rpmkey (
  $ensure = present,
  $source = undef,
) {
  $key_id = $name

  if $source == undef {
    fail("Source is not defined for ${key_id}")
  }
  # create the key
  rpmkey { $key_id:
    ensure => $ensure,
    source => $source,
  }
}
