# ## Class: rpmkey ##
#
# This module manages RPM keys for fedora based systems.
#

class rpmkey (
  $rpmkeys = undef,
  $rpmkeys_hiera_merge = false,
) {

  if is_string($rpmkeys_hiera_merge) {
    $rpmkeys_hiera_merge_real = str2bool($rpmkeys_hiera_merge)
  } else {
    $rpmkeys_hiera_merge_real = $rpmkeys_hiera_merge
  }
  validate_bool($rpmkeys_hiera_merge_real)

  if $rpmkeys_hiera_merge_real == true {
    $rpmkeys_real = hiera_hash('rpmkey::rpmkeys')
  } else {
    $rpmkeys_real = $rpmkeys
  }
  if $rpmkeys_real {
    create_resources(rpmkey, $rpmkeys_real, { ensure => present })
  }
}
