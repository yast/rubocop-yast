Feature: Builtins.getenv()

  Builtins.getenv() call can be easily replaced by ENV hash access.
  We just need to keep the original parameter.

  Scenario: With string literal parameter it is translated to ENV equivalent
    Given the original code is
      """
      Builtins.getenv("foo")
      """
    When the cop Yast/Builtins autocorrects it
    Then the code is converted to
      """
      ENV["foo"]
      """

  Scenario: Variable as the parameter is preserved
    Given the original code is
      """
      foo = bar
      Builtins.getenv(foo)
      """
    When the cop Yast/Builtins autocorrects it
    Then the code is converted to
      """
      foo = bar
      ENV[foo]
      """

  Scenario: Any other statement is preserved
    Given the original code is
      """
      Builtins.getenv(Ops.add(foo, bar))
      """
    When the cop Yast/Builtins autocorrects it
    Then the code is converted to
      """
      ENV[Ops.add(foo, bar)]
      """
