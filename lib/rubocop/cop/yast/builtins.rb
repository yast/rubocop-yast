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
          :dpgettext
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
      end
    end
  end
end
