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
        # Ops replacement mapping
        REPLACEMENT = {
          add: :+
        }

        def initialize(config = nil, options = nil)
          super(config, options)

          @strict_mode = cop_config && cop_config["StrictMode"]
          @replaced_nodes = []
          @processor = OpsProcessor.new(self)
        end

        def investigate(processed_source)
          @processor.investigate(processed_source)
        end

        attr_reader :strict_mode

        private

        def autocorrect(node)
          return unless @processor.autocorrectable?(node)

          _ops, message, arg1, arg2 = *node

          new_op = REPLACEMENT[message]
          return unless new_op

          @corrections << lambda do |corrector|
            source_range = node.loc.expression
            next if contains_comment?(source_range.source)
            new_node = Parser::AST::Node.new(:send, [arg1, new_op, arg2])
            corrector.replace(source_range, Unparser.unparse(new_node))
          end
        end

        def contains_comment?(string)
          /^[^'"\n]*#/.match(string)
        end
      end
    end
  end
end

# Niceness processor really
class OpsProcessor < Parser::AST::Processor
  include RuboCop::Yast::TrackVariableScope

  attr_reader :cop

  def initialize(cop)
    @cop = cop
  end

  def investigate(processed_source)
    process(processed_source.ast)
  end

  MSG = "Obsolete Ops.%s call found"

  def on_send(node)
    super
    return unless call?(node, :Ops, :add)
    return unless cop.strict_mode || autocorrectable?(node)
    cop.add_offense(node, :selector, format(MSG, :add))
  end

  # assumes node is an Ops.add
  def autocorrectable?(node)
    RuboCop::Yast.logger.debug "AUTOCORRECTABLE?(#{node.inspect})"
    RuboCop::Yast.logger.debug "CUR SCOPE #{scope.inspect}"

    _ops, _method, a, b = *node
    nice(a) && nice(b)
  end

  def call?(node, namespace, message)
    n_receiver, n_message = *node
    n_receiver && n_receiver.type == :const &&
      n_receiver.children[0].nil? &&
      n_receiver.children[1] == namespace &&
      n_message == message
  end
end
