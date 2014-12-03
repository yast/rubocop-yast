# encoding: utf-8

module RuboCop
  module Cop
    module Yast
      # This cop checks for using obsoleted Yast Builtins calls
      class Builtins < Cop
        include AST::Sexp

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

        def on_send(node)
          receiver, method_name, *_args = *node

          return if !BUILTINS_NODES.include?(receiver) ||
              ALLOWED_FUNCTIONS.include?(method_name)

          add_offense(node, :selector, format(MSG, method_name))
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            _builtins, message, args = *node

            new_code = builtins_replacement(message, args)

            corrector.replace(node.loc.expression, new_code) if new_code
          end
        end

        private

        def builtins_replacement(message, args)
          case message
          when :getenv
            "ENV[#{args.loc.expression.source}]"
          when :time
            "::Time.now.to_i"
          end
        end
      end
    end
  end
end
