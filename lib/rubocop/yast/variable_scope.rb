# Tracks state for a variable
class VariableState
  def nice
    RuboCop::Yast.logger.debug "GETN #{inspect}"
    @nice
  end

  def nice=(v)
    @nice = v
    RuboCop::Yast.logger.debug "SETN #{inspect}"
    v
  end
end

# Tracks state for local variables visible at certain point.
# Keys are symbols, values are VariableState
class VariableScope < Hash
  def initialize
    super do |hash, key|
      hash[key] = VariableState.new
    end
  end

  # Deep copy the VariableState values
  def dup
    copy = self.class.new
    each do |k, v|
      copy[k] = v.dup
    end
    copy
  end

  # @return [VariableState] state
  def [](varname)
    v = super
    RuboCop::Yast.logger.debug "GET #{varname} -> #{v}"
    v
  end

  # Set state for a variable
  def []=(varname, state)
    RuboCop::Yast.logger.debug "SET #{varname} -> #{state}"
    super
  end

  alias variable? key?
end

# A stack of VariableScope
class VariableScopeStack
  def initialize
    outer_scope = VariableScope.new
    @stack = [outer_scope]
  end

  # The innermost, or current VariableScope
  def innermost
    @stack.last
  end

  # Run *block* using a new clean scope
  # @return the scope as the block left it, popped from the stack
  def with_new(&block)
    @stack.push VariableScope.new
    RuboCop::Yast.logger.debug "SCOPES #{@stack.inspect}"
    block.call
    @stack.pop
  end

  # Run *block* using a copy of the innermost scope
  # @return the scope as the block left it, popped from the stack
  def with_copy(&block)
    @stack.push innermost.dup
    block.call
    @stack.pop
  end
end
