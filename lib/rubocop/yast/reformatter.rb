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
        format.gsub(/%./) do |match|
          case match
          when "%%"
            "%"
          when /%([1-9])/
            pos = Regexp.last_match[1].to_i - 1
            "\#{" + args[pos] + "}" if pos < args.size
          end
        end
      end
    end
  end
end
