Feature: literals

  String and integer literals are obviously nice. nil is a literal too but
  it is ugly.

  Scenario: translates `Ops.add` of two string literals
    Given the original code is "Ops.add("Hello", "World")"
    When the cop Yast/Ops autocorrects it
    Then the code is converted to ""Hello" + "World""

  Scenario: translates `Ops.add` of two integer literals
    Given the original code is "Ops.add(40, 2)"
    When the cop Yast/Ops autocorrects it
    Then the code is converted to "40 + 2"

  Scenario: translates assignment of `Ops.add` of two string literals
    Given the original code is "v = Ops.add("Hello", "World")"
    When the cop Yast/Ops autocorrects it
    Then the code is converted to "v = "Hello" + "World""

  Scenario: does not translate Ops.add if any argument is ugly
    Given the original code is "Ops.add("Hello", world)"
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

  Scenario: does not translate Ops.add if any argument is the nil literal
    Given the original code is "Ops.add("Hello", nil)"
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged
