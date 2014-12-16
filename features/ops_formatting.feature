Feature: formatting

  Scenario: does not translate `Ops.add` if any argument has a comment
    Given the original code is
      """
      Ops.add(
        "Hello",
        # foo
        "World"
      )
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

