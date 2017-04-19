# encoding: utf-8

require "rubocop/cop/cop"

module RuboCop
  module Cop
    module Yast
      # This cop checks for using log variable
      # code like:
      #   log = "msg"
      # can override the included logger
      class LogVariable < Cop
        MSG = "Do not use `log` variable, it can conflict with the logger."
          .freeze

        def on_lvasgn(node)
          name, _value = *node

          add_offense(node, :name, MSG) if name == :log
        end
      end
    end
  end
end
