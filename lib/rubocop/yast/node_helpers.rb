
module RuboCop
  module Yast
    # helpers for traversing the AST tree
    module NodeHelpers
      # Find the parend node of the requested type
      # @param [Array<Symbol>] types requested node types
      # @param node
      # @return the requested type node or the root node if not found
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
