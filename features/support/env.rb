# encoding: utf-8

require "simplecov"
require "rspec"

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
end

# reuse the Rubocop helper, provides some nice methods used in tests
require File.join(Gem::Specification.find_by_name("rubocop").gem_dir, "spec",
  "support", "cop_helper.rb")
include CopHelper

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "rubocop-yast"
