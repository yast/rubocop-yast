# encoding: utf-8

require "rubocop/yast/reformatter"

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

        def on_send(node)
          receiver, method_name, *_args = *node

          return if !BUILTINS_NODES.include?(receiver) ||
              ALLOWED_FUNCTIONS.include?(method_name)

          add_offense(node, :selector, format(MSG, method_name))
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            _builtins, message, *args = *node

            new_code = builtins_replacement(node, message, args)

            corrector.replace(node.loc.expression, new_code) if new_code
          end
        end

        private

        def builtins_replacement(node, message, args)
          case message
          when :getenv
            "ENV[#{args.first.loc.expression.source}]"
          when :time
            "::Time.now.to_i"
          when :y2debug, :y2milestone, :y2warning, :y2error,
              :y2security, :y2internal
            replace_logging(node, message, args)
          end
        end

        def replace_logging(_node, message, args)
          format, *params = *args

          # we can replace only standard logging, not backtraces like
          # Builtins.y2milestone(-1, "foo")
          return unless format.type == :str

          method = DEBUG_REPLACEMENENTS[message]
          return unless method

          src_params = params.map { |arg| arg.loc.expression.source }
          src_format = format.loc.expression.source
          "log.#{method} #{interpolate(src_format, src_params)}"
        end
      end
    end
  end
end
