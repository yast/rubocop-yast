Feature: chained translation

  Scenario: translates a left-associative  chain of nice zombies
    Given the original code is "Ops.add(Ops.add(1, 2), 3)"
    When the cop Yast/Ops autocorrects it
    Then the code is converted to "(1 + 2) + 3"

  Scenario: translates a right-associative chain of nice zombies
    Given the original code is "Ops.add(1, Ops.add(2, 3))"
    When the cop Yast/Ops autocorrects it
    Then the code is converted to "1 + (2 + 3)"

  Scenario: translates `Ops.add` of plus and literal
    Given the original code is "Ops.add("Hello" + " ", "World")"
    When the cop Yast/Ops autocorrects it
    Then the code is converted to "("Hello" + " ") + "World""

  Scenario: translates `Ops.add` of parenthesized plus and literal
    Given the original code is "Ops.add(("Hello" + " "), "World")"
    When the cop Yast/Ops autocorrects it
    Then the code is converted to "("Hello" + " ") + "World""

  Scenario: translates `Ops.add` of literal and plus
    Given the original code is "Ops.add("Hello", " " + "World")"
    When the cop Yast/Ops autocorrects it
    Then the code is converted to ""Hello" + (" " + "World")"
