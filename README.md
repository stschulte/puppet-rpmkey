Puppet RPMKEY Module
====================

[![Build Status](https://travis-ci.org/stschulte/puppet-rpmkey.png?branch=master)](https://travis-ci.org/stschulte/puppet-rpmkey)

This repository aims to ease the GPG keymanagement with rpm

New facts
---------
(currently none)

New functions
-------------
(currently none)

New custom types
----------------

### rpmkey

A package maintainer can sign his RPM packages with a gpg key. The signed RPM package can later be
verified by the rpm utility if the corresponding public key of the package maintainer is present.
RPM has its own keyring and commands to import and remove keys.

A key can be imported with `rpm --import` and will then present itself as an installed package of the form
`gpgkey-#{keyid}-#{signature_date}`. A key can be removed by removing the package with `rpm -e`.

The new puppet `rpmkey` type treats a single key as resource so you can e.g. specify

    rpmkey { '0608B895':
      ensure => present,
      source => 'https://fedoraproject.org/static/0608B895.txt',
    }

or - if you want to make sure a key is deleted - specify

    rpmkey { '0608B895':
      ensure => absent,
    }

The `name` of the `rpmkey` resource has to be the keyID of the gpg key.
The keyID can be found via gpg by passing it the path to an existing key.
For example, to find the keyID used by EPEL 7:

    $ gpg ./RPM-GPG-KEY-EPEL-7
    pub  4096R/352C64E5 2013-12-16 Fedora EPEL (7) <epel@fedoraproject.org>

The string after the / is what `rpmkey` expects (`352C64E5`).

Running the tests
-----------------

This project requires the `puppetlabs_spec_helper` gem (available on rubygems.org)
to run the spec tests. You can run them by executing `rake spec`.

Contribution
------------

Thanks to the following contributers, who made this module more usable:

* Gene Liverman
* Michael Moll
