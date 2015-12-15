require "set"

# Niceness of a node means that it cannot be nil.
#
# Note that the module depends on the includer
# to provide #scope (for #nice_variable)
module Niceness
  # Literals are nice, except the nil literal.
  NICE_LITERAL_NODE_TYPES = [
    :self,
    :false, :true,
    :int, :float,
    :str, :sym, :regexp,
    :array, :hash, :pair, :irange, # may contain nils but they are not nil
    :dstr,                      # "String #{interpolation}" mixes :str, :begin
    :dsym                       # :"#{foo}"
  ].to_set

  def nice(node)
    nice_literal(node) || nice_variable(node) || nice_send(node) ||
      nice_sformat(node) || nice_begin(node)
  end

  def nice_literal(node)
    NICE_LITERAL_NODE_TYPES.include? node.type
  end

  def nice_variable(node)
    node.type == :lvar && scope[node.children.first].nice
  end

  # Methods that preserve niceness if all their arguments are nice
  # These are global, called with a nil receiver
  NICE_GLOBAL_METHODS = {
    # message, number of arguments
    _: 1
  }.freeze

  NICE_OPERATORS = {
    # message, number of arguments (other than receiver)
    :+ => 1
  }.freeze

  def nice_send(node)
    return false unless node.type == :send
    receiver, message, *args = *node

    if receiver.nil?
      arity = NICE_GLOBAL_METHODS.fetch(message, -1)
    else
      return false unless nice(receiver)
      arity = NICE_OPERATORS.fetch(message, -1)
    end
    args.size == arity && args.all? { |a| nice(a) }
  end

  # Builtins.sformat is special in that it can produce nil
  # but only if the format string is nil which is fortunately
  # easy to rule out. Other args may be ugly but we don't care.
  def nice_sformat(node)
    return false unless node.type == :send
    return false unless call?(node, :Builtins, :sformat)
    _builtins, _sformat, format_string, *_other_args = *node
    nice(format_string)
  end

  def nice_begin(node)
    node.type == :begin && nice(node.children.last)
  end

  def call?(node, namespace, message)
    n_receiver, n_message = *node
    n_receiver && n_receiver.type == :const &&
      n_receiver.children[0].nil? &&
      n_receiver.children[1] == namespace &&
      n_message == message
  end
end
