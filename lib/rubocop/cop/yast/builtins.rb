# encoding: utf-8

require "rubocop/yast/reformatter"
require "rubocop/yast/track_variable_scope"

module RuboCop
  module Cop
    module Yast
      # This cop checks for using obsoleted Yast Builtins calls
      class Builtins < Cop
        include AST::Sexp
        include RuboCop::Yast::Reformatter

        MSG = "Builtin call `%s` is obsolete, use native Ruby function instead."

        # white list of allowed Builtins calls
        ALLOWED_FUNCTIONS = [
          # locale dependent sorting in not available in Ruby stdlib
          :lsort,
          # gettext helpers
          :dgettext,
          :dngettext,
          :dpgettext,
          # crypt* helpers
          :crypt,
          :cryptmd5,
          :cryptblowfish,
          :cryptsha256,
          :cryptsha512
        ]

        BUILTINS_NODES = [
          # Builtins.*
          s(:const, nil, :Builtins),
          # Yast::Builtins.*
          s(:const, s(:const, nil, :Yast), :Builtins),
          # ::Yast::Builtins.*
          s(:const, s(:const, s(:cbase), :Yast), :Builtins)
        ]

        DEBUG_REPLACEMENENTS = {
          y2debug: "debug",
          y2milestone: "info",
          y2warning: "warn",
          y2error: "error",
          y2security: "error",
          y2internal: "fatal"
        }

        ASGN_TYPES = [
          :lvasgn,
          :op_asgn,
          :or_asgn,
          :and_asgn
        ]

        REPLACEABLE = DEBUG_REPLACEMENENTS.keys + [:getenv, :time]

        def on_send(node)
          receiver, method_name, *_args = *node

          return if !BUILTINS_NODES.include?(receiver) ||
              ALLOWED_FUNCTIONS.include?(method_name)

          ignore_node(node) if ignore_logging_node?(node)

          add_offense(node, :selector, format(MSG, method_name))
        end

        def autocorrect(node)
          _builtins, message, *args = *node

          if !REPLACEABLE.include?(message) || ignored_node?(node)
            raise CorrectionNotPossible
          end

          @corrections << lambda do |corrector|
            new_code = builtins_replacement(node, corrector, message, args)
            return unless new_code

            corrector.replace(node.loc.expression, new_code)
          end
        end

        private

        def ignore_logging_node?(node)
          _receiver, method_name, *_args = *node

          # not a logging node
          return false unless DEBUG_REPLACEMENENTS.key?(method_name)

          target_node = parent_node_type(node, [:class, :module])

          log_descendant = target_node.each_descendant.find do |n|
            n && ASGN_TYPES.include?(n.type) && n.loc.name.source == "log"
          end

          log_descendant
        end

        def builtins_replacement(node, corrector, message, args)
          return if ignored_node?(node)

          case message
          when :getenv
            "ENV[#{args.first.loc.expression.source}]"
          when :time
            "::Time.now.to_i"
          when :y2debug, :y2milestone, :y2warning, :y2error,
              :y2security, :y2internal
            replace_logging(node, corrector, message, args)
          end
        end

        def replace_logging(node, corrector, message, args)
          format, *params = *args

          # we can replace only standard logging, not backtraces like
          # Builtins.y2milestone(-1, "foo")
          return unless format.type == :str

          method = DEBUG_REPLACEMENENTS[message]
          return unless method

          src_params = params.map { |arg| arg.loc.expression.source }
          src_format = format.loc.expression.source

          add_logger_include(node, corrector)
          "log.#{method} #{interpolate(src_format, src_params)}"
        end
      end
    end
  end
end
