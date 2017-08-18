source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'] : ['>= 2.7']
facterversion = ENV.key?('FACTER_VERSION') ? ENV['FACTER_VERSION'] : ['>= 1.6']

gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'facter', facterversion

# rspec must be v2 for ruby 1.8.7
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('1.8.7') and Gem::Version.new(RUBY_VERSION) < Gem::Version.new('1.9')
  gem 'rspec', '~> 3.1.0'
end

## Puppet 2.7 does not include hiera.
if puppetversion =~ /^([^0-9]+)?([^\.]|)2(\..*?)$/
  gem 'hiera'
  gem 'hiera-puppet'
end

unless RUBY_VERSION =~ /^1.8/
  gem 'coveralls', :require => false
end
