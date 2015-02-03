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
  SimpleCov.start
  SimpleCov.start do
    add_filter 'spec/'
  end
end
