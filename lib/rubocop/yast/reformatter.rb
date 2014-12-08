# encoding: utf-8

require "yaml"

module RuboCop
  module Yast
    # patch the Rubocop config - include the plugin defaults
    module Reformatter
      # converts YCP format string to Ruby interpolation
      # @param [String] format YCP format string (e.g. "foo: %1")
      # @param [Array<String>] args argument list
      # @return [String] String with Ruby interpolation
      def interpolate(format, args)
        single_to_double(format).gsub(/%./) do |match|
          case match
          when "%%"
            "%"
          when /%([1-9])/
            pos = Regexp.last_match[1].to_i - 1
            "\#{" + args[pos] + "}" if pos < args.size
          end
        end
      end

      # convert single quoted string to double quoted to allow using string
      # interpolation
      def single_to_double(str)
        ret = str.dup
        return ret if str.start_with?("\"")

        # esacpe interpolation start (ignred in single quoted string)
        ret.gsub!("\#{", "\\\#{")
        # esacpe double quotes (not needed in single quoted string)
        ret.gsub!("\"", "\\\"")

        # replace the around quotes
        ret[0] = "\""
        ret[-1] = "\""
        ret
      end
    end
  end
end
