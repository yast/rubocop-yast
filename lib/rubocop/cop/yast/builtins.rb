# encoding: utf-8

require "rubocop/yast/builtin_call"

module RuboCop
  module Cop
    module Yast
      # This cop checks for using obsoleted Yast Builtins calls
      class Builtins < Cop
        include AST::Sexp

        attr_reader :handlers, :default_handler

        MSG = "Builtin call `%s` is obsolete, use native Ruby function instead."

        BUILTINS_NODES = [
          # Builtins.*
          s(:const, nil, :Builtins),
          # Yast::Builtins.*
          s(:const, s(:const, nil, :Yast), :Builtins),
          # ::Yast::Builtins.*
          s(:const, s(:const, s(:cbase), :Yast), :Builtins)
        ]

        def initialize(config = nil, options = nil)
          super(config, options)

          @handlers = builtin_mapping
          @default_handler = RuboCop::Yast::BuiltinCall.new
        end

        def on_send(node)
          receiver, method_name, *_args = *node

          # not an Yast builtin call or not an offense
          return if !BUILTINS_NODES.include?(receiver) ||
              !builtin_handler(method_name).offense?(node)

          add_offense(node, :selector, format(MSG, method_name))
        end

        def autocorrect(node)
          _builtins, method_name, *_args = *node

          @corrections << builtin_handler(method_name).correction(node)
        end

        private

        def builtin_mapping
          {
            y2debug: RuboCop::Yast::Y2debugCall.new,
            y2milestone: RuboCop::Yast::Y2milestoneCall.new,
            y2warning: RuboCop::Yast::Y2warningCall.new,
            y2error: RuboCop::Yast::Y2errorCall.new,
            y2security: RuboCop::Yast::Y2securityCall.new,
            y2internal: RuboCop::Yast::Y2internalCall.new,

            getenv: RuboCop::Yast::GetenvCall.new,
            time: RuboCop::Yast::TimeCall.new
          }
        end

        def builtin_handler(method)
          handlers[method] || default_handler
        end
      end
    end
  end
end
