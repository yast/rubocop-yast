
# RuboCop::Cop::CorrectionNotPossible exception
require "rubocop/cop/cop"

require "rubocop/yast/reformatter"
require "rubocop/yast/node_helpers"

module RuboCop
  module Yast
    # generic class for handling Yast builtins
    class BuiltinCall
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

      def offense?(node)
        _receiver, method_name, *_args = *node
        !ALLOWED_FUNCTIONS.include?(method_name)
      end

      def correction(_node)
        raise RuboCop::Cop::CorrectionNotPossible
      end
    end

    # getenv() convertor
    class GetenvCall < BuiltinCall
      def correction(node)
        lambda do |corrector|
          _builtins, _message, *args = *node
          new_code = "ENV[#{args.first.loc.expression.source}]"
          corrector.replace(node.loc.expression, new_code)
        end
      end
    end

    # time() convertor
    class TimeCall < BuiltinCall
      def correction(node)
        lambda do |corrector|
          corrector.replace(node.loc.expression, "::Time.now.to_i")
        end
      end
    end

    # generic class for handling logging builtins
    class Y2logCall < BuiltinCall
      include Reformatter
      include NodeHelpers

      LOGGING_REPLACEMENENTS = {
        y2debug: "debug",
        y2milestone: "info",
        y2warning: "warn",
        y2error: "error",
        y2security: "error",
        y2internal: "fatal"
      }

      ASGN_TYPES = [
        :lvasgn,
        :op_asgn,
        :or_asgn,
        :and_asgn
      ]

      def correction(node)
        _receiver, _method_name, format, *_params = *node

        # we can replace only standard logging, not backtraces like
        # Builtins.y2milestone(-1, "foo")
        if !format.str_type? || ignore_node?(node)
          raise RuboCop::Cop::CorrectionNotPossible
        end

        correction_lambda(node)
      end

      private

      def correction_lambda(node)
        lambda do |corrector|
          add_missing_logger(node, corrector)

          corrector.replace(node.loc.expression, replacement(node))
        end
      end

      def replacement(node)
        _receiver, method_name, format, *params = *node

        src_params = params.map { |p| p.loc.expression.source }
        src_format = format.loc.expression.source
        method = LOGGING_REPLACEMENENTS[method_name]

        "log.#{method} #{interpolate(src_format, src_params)}"
      end

      def ignore_node?(node)
        target_node = parent_node_type(node, [:class, :module])

        log_descendant = target_node.each_descendant.find do |n|
          n && ASGN_TYPES.include?(n.type) && n.loc.name.source == "log"
        end

        log_descendant
      end

      # Add Yast::Logger include somewhere up in the tree
      def add_missing_logger(node, corrector)
        target_node = parent_node_type(node, [:class, :module])

        # already added or already present
        return if added_includes_nodes.include?(target_node) ||
            logger_included?(target_node)

        add_include_to_node(target_node, corrector)

        added_includes_nodes << target_node
      end

      # add the Yast::LOgger statement include to this node
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

      # remember the added iclude nodes to avoid multiple additions
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
        # TODO: better check for the include call, this is a simple "grep"...
        !source.match(/include\s+(Yast::|)Logger/).nil?
      end

      # format the include statement
      def logger_include_code(indent = nil)
        code = "include Yast::Logger\n"
        return code unless indent

        indent_str = "\n" + " " * (indent + 2)
        indent_str + code
      end
    end

    class Y2debugCall < Y2logCall; end
    class Y2milestoneCall < Y2logCall; end
    class Y2warningCall < Y2logCall; end
    class Y2errorCall < Y2logCall; end
    class Y2securityCall < Y2logCall; end
    class Y2internalCall < Y2logCall; end
  end
end
