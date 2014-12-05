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
        include RuboCop::Yast::TrackVariableScope

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

        REPLACABLE = DEBUG_REPLACEMENENTS.keys + [:getenv, :time]

        def on_send(node)
          receiver, method_name, *_args = *node

          return if !BUILTINS_NODES.include?(receiver) ||
              ALLOWED_FUNCTIONS.include?(method_name)

          add_offense(node, :selector, format(MSG, method_name))
        end

        def autocorrect(node)
          _builtins, message, *args = *node

          raise CorrectionNotPossible unless REPLACABLE.include?(message)

          @corrections << lambda do |corrector|
            new_code = builtins_replacement(node, corrector, message, args)
            return unless new_code

            corrector.replace(node.loc.expression, new_code)
          end
        end

        private

        def builtins_replacement(node, corrector, message, args)
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
