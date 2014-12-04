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
        target_node = parent_node_type(node, [:class, :module])

        # already added or already present
        return if added_includes_nodes.include?(target_node) ||
            logger_included?(target_node)

        add_include_to_node(target_node, corrector)

        added_includes_nodes << target_node
      end

      private

      def add_include_to_node(node, corrector)
        if node.class_type? || node.module_type?
          # indent the include statement
          corrector.insert_after(class_logger_pos(node),
            logger_include_code(node.loc.keyword.column))
        else
          # otherwise put it at the top
          corrector.insert_before(node.loc.expression, logger_include_code)
        end
      end

      def added_includes_nodes
        @added_include_nodes ||= []
      end

      # insert after "class Foo" or "class Foo < Bar" statement
      def class_logger_pos(node)
        node.loc.operator ? node.children[1].loc.expression :  node.loc.name
      end

      # simple check for already present include
      def logger_included?(node)
        return false if node.nil? || node.loc.nil?

        source = node.loc.expression.source
        !source.match(/include\s+(Yast::|)Logger/).nil?
      end

      def logger_include_code(indent = nil)
        code = "include Yast::Logger\n"
        return code unless indent

        indent_str = "\n" + " " * (indent + indentation_width)
        indent_str + code
      end

      def indentation_width
        config.for_cop("IndentationWidth")["Width"]
      end

      def parent_node_type(node, types)
        target_node = node

        # find parent "class" node or the root node
        while !target_node.root? && !types.include?(target_node.type)
          target_node = target_node.parent
        end

        target_node
      end
    end
  end
end
