# encoding: utf-8

require "rubocop/yast/track_variable_scope"
require "unparser"

# We have encountered code that does satisfy our simplifying assumptions,
# translating it would not be correct.
class TooComplexToTranslateError < Exception
end

module RuboCop
  module Cop
    module Yast
      # This cop checks for Ops.* calls aka Zombies.
      # Some of these can be autocorrected, mostly when we can prove
      # that their arguments cannot be nil.
      # In Strict Mode, it reports all zombies.
      # In Permissive Mode, it report only zombies that can be autocorrected.
      class Ops < Cop
        include RuboCop::Yast::TrackVariableScope

        # Ops replacement mapping
        REPLACEMENT = {
          add: :+
        }

        MSG = "Obsolete Ops.%s call found"

        def initialize(config = nil, options = nil)
          super(config, options)

          @strict_mode = cop_config && cop_config["StrictMode"]
          @replaced_nodes = []
        end

        def on_send(node)
          return unless call?(node, :Ops, :add)
          return unless strict_mode || autocorrectable?(node)
          add_offense(node, :selector, format(MSG, :add))
        end

        private

        def call?(node, namespace, message)
          n_receiver, n_message = *node
          n_receiver && n_receiver.type == :const &&
            n_receiver.children[0].nil? &&
            n_receiver.children[1] == namespace &&
            n_message == message
        end

        # assumes node is an Ops.add
        def autocorrectable?(node)
          _ops, _method, a, b = *node
          nice(a) && nice(b)
        end

        def autocorrect(node)
          return unless autocorrectable?(node)

          _ops, message, arg1, arg2 = *node

          new_op = REPLACEMENT[message]
          return unless new_op

          @corrections << lambda do |corrector|
            source_range = node.loc.expression
            new_node = Parser::AST::Node.new(:send, [arg1, new_op, arg2])
            corrector.replace(source_range, Unparser.unparse(new_node))
          end
        end
        attr_reader :strict_mode
      end
    end
  end
end
