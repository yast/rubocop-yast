# encoding: utf-8

require "simplecov"
require "rspec"
require "rubocop/rspec/cop_helper"

# use coveralls for on-line code coverage reporting at Travis CI
if ENV["TRAVIS"]
  require "coveralls"

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
end

SimpleCov.start do
  # don't check code coverage in these subdirectories
  add_filter "/vendor/"
  add_filter "/features/"
end

# allow only the new "expect" RSpec syntax
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include CopHelper
  config.full_backtrace = true
end

# a bad hack. including CopHelper in the RSpec example is not enough
# because Cucumber runs it elsewhere
module RSpec::Matchers
  def self.let(symbol, &block)
    define_method(symbol, block)
  end
  include CopHelper
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "rubocop-yast"
