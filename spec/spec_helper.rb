require 'rubygems'

unless RUBY_VERSION =~ /^1.8/
  require 'simplecov'
  require 'coveralls'
end

require 'puppetlabs_spec_helper/module_spec_helper'

unless RUBY_VERSION =~ /^1.8/
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start do
    add_filter 'spec/'
  end
end


RSpec.configure do |c|
    c.hiera_config = File.expand_path(File.join(__FILE__, '../fixtures/hiera.yaml'))
end
