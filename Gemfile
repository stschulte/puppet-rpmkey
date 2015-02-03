source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'] : ['>= 2.7']
facterversion = ENV.key?('FACTER_VERSION') ? ENV['FACTER_VERSION'] : ['>= 1.6']

gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'facter', facterversion

unless RUBY_VERSION =~ /^1.8/
  gem 'coveralls', :require => false
end
