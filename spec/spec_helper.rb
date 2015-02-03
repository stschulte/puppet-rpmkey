require 'rubygems'
require 'simplecov'
require 'coveralls'
require 'puppetlabs_spec_helper/module_spec_helper'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start
SimpleCov.start do
  add_filter 'spec/'
end
