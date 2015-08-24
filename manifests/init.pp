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
    $rpmkeys_real = hiera_hash('rpmkeys::rpmkeys')
  } else {
    $rpmkeys_real = $rpmkeys
  }
  # Check for hiera merge true / false
  create_resources('rpmkey::rpmkey', $rpmkeys_real)
}
