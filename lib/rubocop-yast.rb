# encoding: utf-8

require "rubocop"

require_relative "rubocop/yast/config"
# FIXME: re-enable this
#RuboCop::Yast::Config.load_defaults

require_relative "rubocop/yast/version"
require_relative "rubocop/yast/logger"
require_relative "rubocop/cop/yast/builtins"
require_relative "rubocop/cop/yast/ops"
require_relative "rubocop/cop/yast/log_variable"
