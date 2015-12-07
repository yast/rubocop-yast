# encoding: utf-8

require "rubocop"

require_relative "rubocop/yast/config"
RuboCop::Yast::Config.load_defaults

require_relative "rubocop/yast/version"
require_relative "rubocop/cop/yast/builtins"
require_relative "rubocop/cop/yast/ops"
require_relative "rubocop/cop/yast/log_variable"
require_relative "rubocop/cop/yast/nice_force"
