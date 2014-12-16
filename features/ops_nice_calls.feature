Feature: calls preserving niceness

  Note: Calls Generating Niceness: `nil?` makes any value a nice value but
  unfortunately it seems of little practical use. Even though there are two
  zombies that have boolean arguments (`Builtins.find` and `Builtins.filter`),
  they are just fine with `nil` since it is a falsey value.

  Scenario: A localized string literal is nice
    Given the original code is
      """
      v = _("Hello")
      Ops.add(v, "World")
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      v = _("Hello")
      v + "World"
      """
