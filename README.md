Puppet RPMKEY Module
====================

[![Build Status](https://travis-ci.org/stschulte/puppet-rpmkey.png?branch=master)](https://travis-ci.org/stschulte/puppet-rpmkey)
[![Coverage Status](https://coveralls.io/repos/stschulte/puppet-rpmkey/badge.svg)](https://coveralls.io/r/stschulte/puppet-rpmkey)
[![Puppet Forge](https://img.shields.io/puppetforge/v/stschulte/rpmkey.svg)](https://forge.puppetlabs.com/stschulte/rpmkey)

This repository aims to ease the GPG keymanagement with rpm

Background
----------

A package maintainer can sign his RPM packages with a secret gpg key.  This
allows a third party (e.g. you) to verify the package with the corresponding
public key. The `rpm` utility has its own keyring and commands to import and
remove public gpg keys.

A key can be imported with `rpm --import` and will then present itself as an
installed package of the form `gpgkey-#{keyid}-#{signature_date}`. In the same
way the key can be removed from the keyring by removing the corresponding
package with `rpm --erase`

The puppet way
--------------

The new puppet `rpmkey` type treats a single key as a puppet resource so you
can e.g. specify

```puppet
rpmkey { '0608B895':
  ensure => present,
  source => 'https://fedoraproject.org/static/0608B895.txt',
}
```

The above resource will import the key if it is not already present. If
you want to make sure that a key is absent (remove it when it is present)
specify the following instead:

```puppet
rpmkey { '0608B895':
  ensure => absent,
}
```

The `name` of the `rpmkey` resource has to be the keyID of the gpg key.  If
you have the public key available as a file but you are unsure of the correct
keyID, use `gpg` to extract the keyID.  For example, to find the keyID used
by EPEL 7:

```bash
$ gpg ./RPM-GPG-KEY-EPEL-7
pub  4096R/352C64E5 2013-12-16 Fedora EPEL (7) <epel@fedoraproject.org>
```

The string after the / is what `rpmkey` expects (`352C64E5`).

Running the tests
-----------------

The easiest way to run the tests is via bundler

```bash
bundle install
bundle exec rake spec SPEC_OPTS='--format documentation'
```

Contribution
------------

Thanks to the following contributers, who made this module more usable:

* Gene Liverman
* Michael Moll
* duritong
