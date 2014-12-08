require "rubocop/yast/builtins/builtin"

module RuboCop
  module Yast
    module Builtins
      # time() convertor
      class Time < Builtin
        def correction(node)
          lambda do |corrector|
            corrector.replace(node.loc.expression, "::Time.now.to_i")
          end
        end
      end
    end
  end
end
