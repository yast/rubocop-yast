
require "rubocop/yast/builtins/builtin"

module RuboCop
  module Yast
    module Builtins
      # getenv() convertor
      class Getenv < Builtin
        def correction(node)
          lambda do |corrector|
            _builtins, _message, *args = *node
            new_code = "ENV[#{args.first.loc.expression.source}]"
            corrector.replace(node.loc.expression, new_code)
          end
        end
      end
    end
  end
end
