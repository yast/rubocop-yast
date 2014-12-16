Feature: translation below top level

  Scenario: translates a zombie nested in other calls
    Given the original code is
      """
      v = 1
      foo(bar(Ops.add(v, 1), baz))
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      v = 1
      foo(bar(v + 1, baz))
      """
