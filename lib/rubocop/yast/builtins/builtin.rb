
module RuboCop
  module Yast
    module Builtins
      # generic class for handling Yast builtins, base class for specific
      # builtins zombie killers
      class Builtin
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
        ].freeze

        def offense?(node)
          _receiver, method_name, *_args = *node
          !ALLOWED_FUNCTIONS.include?(method_name)
        end

        def correction(_node)
          false
        end
      end
    end
  end
end
