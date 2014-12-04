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

      def add_logger_include(node, corrector)
        target_node = parent_node_type(node, :class)

        return if logger_included?(target_node)
        loc = target_node.loc

        if target_node.type == :class
          # indent the include statement
          column = loc.keyword.column
          # insert after "class Foo" statement
          corrector.insert_after(loc.name, logger_include(column))
        else
          # otherwise put it at the top
          corrector.insert_before(loc.expression, logger_include)
        end
      end

      # simple check for already present include
      def logger_included?(node)
        source = node.loc.expression.source
        !source.match(/include\s+(Yast::|)Logger/).nil?
      end

      def logger_include(indent = nil)
        code = "include Yast::Logger\n"
        return code unless indent

        indent_str = "\n" + " " * (indent + indentation_width)
        indent_str + code
      end

      def indentation_width
        config.for_cop("IndentationWidth")["Width"]
      end

      def parent_node_type(node, type)
        target_node = node

        # find parent "class" node or the root node
        while !target_node.root? && target_node.type != type
          target_node = target_node.parent
        end

        target_node
      end
    end
  end
end
