# encoding: utf-8

require "rubocop/yast/niceness"
require "rubocop/yast/track_variable_scope"

# We have encountered code that does satisfy our simplifying assumptions,
# translating it would not be correct.
class TooComplexToTranslateError < Exception
end

module RuboCop
  module Cop
    module Yast
      # This cop checks for Ops.* calls, it can autocorrect safe places or
      # all places in unsafe mode
      class Ops < Cop
        include Niceness
        include ::RuboCop::Yast::TrackVariableScope

        # Ops replacement mapping
        REPLACEMENT = {
          add: "+"
        }

        MSG = "Obsolete Ops.%s call found"

        def initialize(config = nil, options = nil)
          super(config, options)

          @safe_mode = cop_config["SafeMode"]
          @replaced_nodes = []
        end

        def on_send(node)
          return unless call?(node, :Ops, :add)

          _ops, method, a, b = *node
          return if !(nice(a) && nice(b)) && safe_mode

          add_offense(node, :selector, format(MSG, method))
        end

        private

        def call?(node, namespace, message)
          n_receiver, n_message = *node
          n_receiver && n_receiver.type == :const &&
            n_receiver.children[0].nil? &&
            n_receiver.children[1] == namespace &&
            n_message == message
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            _ops, message, arg1, arg2 = *node

            new_ops = REPLACEMENT[message]
            return unless new_ops

            corrector.replace(node.loc.expression,
              ops_replacement(new_ops, arg1, arg2))
          end
        end

        def ops_replacement(new_ops, arg1, arg2)
          "#{arg1.loc.expression.source} #{new_ops} " \
            "#{arg2.loc.expression.source}"
        end

        attr_reader :safe_mode
      end
    end
  end
end
