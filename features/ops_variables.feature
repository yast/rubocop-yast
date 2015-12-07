Feature: variables

  If a local variable is assigned a nice value, we remember that.

  We chose to ignore multiple assigments for now because of their complicated
  semantics (especially in presence of splats).

  Scenario: translates `Ops.add(nice_variable, literal)`
    Given the original code is
      """
      v = "Hello"
      Ops.add(v, "World")
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      v = "Hello"
      v + "World"
      """

  Scenario: doesn't translate `Ops.add(nice_variable, literal)` when the variable got it's niceness via multiple assignemnt
    Given the original code is
      """
      v1, v2 = "Hello", "World"
      Ops.add(v1, v2)
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

  Scenario: translates `Ops.add(nontrivially_nice_variable, literal)`
    Given the original code is
      """
      v  = "Hello"
      v2 = v
      v  = uglify
      Ops.add(v2, "World")
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      v  = "Hello"
      v2 = v
      v  = uglify
      v2 + "World"
      """

  Scenario: does not translate `Ops.add(mutated_variable, literal)`
    Given the original code is
      """
      v = "Hello"
      v = f(v)
      Ops.add(v, "World")
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

  Scenario: does not confuse variables across `def`s
    Given this gets implemented
    Given the original code is
      """
      def a
        v = "literal"
      end

      def b(v)
        Ops.add(v, "literal")
      end
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

  Scenario: does not confuse variables across `def self.`s
    Given this gets implemented
    Given the original code is
      """
      v = 1

      def self.foo(v)
        Ops.add(v, 1)
      end
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

  Scenario: does not confuse variables across `module`s
    Given this gets implemented
    Given the original code is
      """
      module A
        v = "literal"
      end

      module B
        # The assignment is needed to convince Ruby parser that the "v"
        # reference in the "Ops.add" call later refers to a variable, not a
        # method. This means it will be parsed as a "lvar" node (which can
        # possibly be nice), not a "send" node (which can't be nice).

        v = v
        Ops.add(v, "literal")
      end
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

  Scenario: does not confuse variables across `class`s
    Given this gets implemented
    Given the original code is
      """
      class A
        v = "literal"
      end

      class B
        # The assignment is needed to convince Ruby parser that the "v"
        # reference in the "Ops.add" call later refers to a variable, not a
        # method. This means it will be parsed as a "lvar" node (which can
        # possibly be nice), not a "send" node (which can't be nice).

        v = v
        Ops.add(v, "literal")
      end
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

  Scenario: does not confuse variables across singleton `class`s
    Given this gets implemented
    Given the original code is
      """
      class << self
        v = "literal"
      end

      class << self
        # The assignment is needed to convince Ruby parser that the "v"
        # reference in the "Ops.add" call later refers to a variable, not a
        # method. This means it will be parsed as a "lvar" node (which can
        # possibly be nice), not a "send" node (which can't be nice).

        v = v
        Ops.add(v, "literal")
      end
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged
