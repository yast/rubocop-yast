# encoding: utf-8

require "rubocop/yast/niceness"
require "rubocop/yast/variable_scope"

# We have encountered code that does satisfy our simplifying assumptions,
# translating it would not be correct.
class TooComplexToTranslateError < Exception
end

module RuboCop
  module Cop
    module Yast
      # This cop check for Ops.* calls and can autocorrect safe places
      class Ops < Cop
        include Niceness

        MSG = "Ops call found"

        def initialize(config = nil, options = nil)
          super

          @scopes = VariableScopeStack.new
          # FIXME: how to pass unsafe option?
          @unsafe = false
        end

        # FIXME
        def process(node)
          return if node.nil?
          #  if ! @unsafe
          #  oops(node, RuntimeError.new("Unknown node type #{node.type}")) \
          #    unless HANDLED_NODE_TYPES.include? node.type
          #  end
        end

        # currently visible scope
        def scope
          scopes.innermost
        end

        def with_new_scope_rescuing_oops(node, &block)
          scopes.with_new do
            block.call if block_given?
          end
        rescue => e
          oops(node, e)
        end

        def on_def(node)
          with_new_scope_rescuing_oops(node)
        end

        def on_defs(node)
          with_new_scope_rescuing_oops(node)
        end

        def on_module(node)
          with_new_scope_rescuing_oops(node)
        end

        def on_class(node)
          with_new_scope_rescuing_oops(node)
        end

        def on_sclass(node)
          with_new_scope_rescuing_oops(node)
        end

        # def on_unless
        # Does not exist.
        # `unless` is parsed as an `if` with then_body and else_body swapped.
        # Compare with `while` and `until` which cannot do that and thus need
        # distinct node types.
        # end

        def on_case(node)
          expr, *cases = *node
          process(expr)

          cases.each do |case_|
            scopes.with_copy do
              process(case_)
            end
          end

          # clean slate
          scope.clear
        end

        def on_lvasgn(node)
          name, value = * node
          return if value.nil? # and-asgn, or-asgn, resbody do this
          scope[name].nice = nice(value)
        end

        def on_and_asgn(node)
          var, value = * node
          return if var.type != :lvasgn
          name = var.children[0]

          scope[name].nice &&= nice(value)
        end

        def on_or_asgn(node)
          var, value = * node
          return if var.type != :lvasgn
          name = var.children[0]

          scope[name].nice ||= nice(value)
        end

        def on_send(node)
          return unless call?(node, :Ops, :add)
          _ops, _add, a, b = *node

          if nice(a) && nice(b)
            # FIXME
            puts "found a zombie to kill"
          else
            # FIXME
            puts "found a scary zombie, don't touch it!"
          end

          add_offense(node, :selector, MSG)
        end

        def on_block(_node)
          # ignore body, clean slate
          scope.clear
        end
        alias_method :on_for, :on_block

        def on_while(_node)
          # ignore both condition and body,
          # with a simplistic scope we cannot handle them

          # clean slate
          scope.clear
        end
        alias_method :on_until, :on_while

        # Exceptions:
        # `raise` is an ordinary :send for the parser

        def on_rescue(node)
          # (:rescue, begin-block, resbody..., else-block-or-nil)
          _begin_body, *_rescue_bodies, _else_body = *node

          # FIXME
          #  @source_rewriter.transaction do
          #    process(begin_body)
          #    process(else_body)
          #    rescue_bodies.each do |r|
          #      process(r)
          #    end
          #  end
          #  rescue TooComplexToTranslateError
          #    warning "begin-rescue is too complex to translate due to a retry"
          #  end
        end

        def on_resbody(_node)
          # How it is parsed:
          # (:resbody, exception-types-or-nil, exception-variable-or-nil, body)
          # exception-types is an :array
          # exception-variable is a (:lvasgn, name), without a value

          # A rescue means that *some* previous code was skipped.
          # We know nothing. We could process the resbodies individually,
          # and join begin-block with else-block, but it is little worth
          # because they will contain few zombies.
          scope.clear
        end

        def on_ensure(_node)
          # (:ensure, guarded-code, ensuring-code)
          # guarded-code may be a :rescue or not

          scope.clear
        end

        def on_retry(_node)
          # that makes the :rescue a loop, top-down data-flow fails
          # FIXME
          # raise TooComplexToTranslateError
        end

        private

        def oops(node, exception)
          puts "Node exception @ #{node.loc.expression}"
          puts "Offending node: #{node.inspect}"
          raise exception unless exception.is_a?(TooComplexToTranslateError)
        end

        def call?(node, namespace, message)
          n_receiver, n_message = *node
          n_receiver && n_receiver.type == :const &&
            n_receiver.children[0].nil? &&
            n_receiver.children[1] == namespace &&
            n_message == message
        end

        # TODO: add autocorrection support
        # def autocorrect(range)
        #   @corrections << lambda do |corrector|
        #     corrector.replace(range, "")
        #   end
        # end

        attr_reader :scopes
      end
    end
  end
end
