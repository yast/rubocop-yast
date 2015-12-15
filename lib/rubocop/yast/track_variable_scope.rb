# encoding: utf-8

require "rubocop/yast/niceness"
require "rubocop/yast/variable_scope"

# We have encountered code that does satisfy our simplifying assumptions,
# translating it would not be correct.
class TooComplexToTranslateError < Exception
end

module RuboCop
  module Yast
    # This module tracks variable usage
    module TrackVariableScope
      include Niceness

      def scopes
        @scopes ||= VariableScopeStack.new
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
        name, _, _ = *node
        RuboCop::Yast.logger.debug "ONDEF #{name}"
        RuboCop::Yast.logger.debug "CUR SCOPE #{scope.inspect}"
        RuboCop::Yast.backtrace skip_frames: 50 if $DEBUG

        with_new_scope_rescuing_oops(node) { super }
      end

      def on_defs(node)
        with_new_scope_rescuing_oops(node) { super }
      end

      def on_module(node)
        with_new_scope_rescuing_oops(node) { super }
      end

      def on_class(node)
        with_new_scope_rescuing_oops(node) { super }
      end

      def on_sclass(node)
        with_new_scope_rescuing_oops(node) { super }
      end

      def on_if(node)
        cond, then_body, else_body = *node
        process(cond)

        scopes.with_copy do
          process(then_body)
        end

        scopes.with_copy do
          process(else_body)
        end

        # clean slate
        scope.clear

        node
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

        node
      end

      def on_lvasgn(node)
        super
        name, value = * node
        return if value.nil? # and-asgn, or-asgn, resbody do this
        scope[name].nice = nice(value)
        node
      end

      def on_and_asgn(node)
        super
        var, value = *node
        bool_op_asgn(var, value, :and)
        node
      end

      def on_or_asgn(node)
        super
        var, value = *node
        bool_op_asgn(var, value, :or)
        node
      end

      def on_block(node)
        # ignore body, clean slate
        scope.clear
        node
      end
      alias_method :on_for, :on_block

      def on_while(node)
        # ignore both condition and body,
        # with a simplistic scope we cannot handle them

        # clean slate
        scope.clear
        node
      end
      alias_method :on_until, :on_while

      # Exceptions:
      # `raise` is an ordinary :send for the parser

      def on_rescue(node)
        # (:rescue, begin-block, resbody..., else-block-or-nil)
        begin_body, *rescue_bodies, else_body = *node

        # FIXME: the transaction must be rolled back
        # by the TooComplexToTranslateError
        # @source_rewriter.transaction do
        process(begin_body)
        process(else_body)
        rescue_bodies.each do |r|
          process(r)
        end
        #  end
        node
      rescue TooComplexToTranslateError
        warn "begin-rescue is too complex to translate due to a retry"
        node
      end

      def on_resbody(node)
        # How it is parsed:
        # (:resbody, exception-types-or-nil, exception-variable-or-nil, body)
        # exception-types is an :array
        # exception-variable is a (:lvasgn, name), without a value

        # A rescue means that *some* previous code was skipped.
        # We know nothing. We could process the resbodies individually,
        # and join begin-block with else-block, but it is little worth
        # because they will contain few zombies.
        scope.clear
        super
      end

      def on_ensure(node)
        # (:ensure, guarded-code, ensuring-code)
        # guarded-code may be a :rescue or not

        scope.clear
        node
      end

      def on_retry(_node)
        # that makes the :rescue a loop, top-down data-flow fails
        raise TooComplexToTranslateError
      end

      private

      def oops(node, exception)
        puts "Node exception @ #{node.loc.expression}"
        puts "Offending node: #{node.inspect}"
        raise exception unless exception.is_a?(TooComplexToTranslateError)
      end

      def bool_op_asgn(var, value, op)
        return if var.type != :lvasgn
        name = var.children[0]

        case op
        when :and
          scope[name].nice &&= nice(value)
        when :or
          scope[name].nice ||= nice(value)
        else
          raise "Unknown operator: #{op}"
        end
      end
    end
  end
end
