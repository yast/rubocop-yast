# encoding: utf-8

require "simplecov"

# use coveralls for on-line code coverage reporting at Travis CI
if ENV["TRAVIS"]
  require "coveralls"

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
end

SimpleCov.minimum_coverage 95

SimpleCov.start do
  # don't check code coverage in these subdirectories
  add_filter "/vendor/"
  add_filter "/spec/"
end

# allow only the new "expect" RSpec syntax
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |c|
    c.syntax = :expect
  end
end

# reuse the Rubocop helper, provides some nice methods used in tests
require File.join(
  Gem::Specification.find_by_name("rubocop").gem_dir, "spec", "spec_helper.rb"
)

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

def code_cleanup(s)
  s.split("\n").reject { |l| l =~ /^\s*$/ }.first =~ /^(\s*)/
  return s.dup if Regexp.last_match.nil?
  s.gsub(Regexp.new("^#{Regexp.last_match[1]}"), "")[0..-2]
end

require "rubocop-yast"
