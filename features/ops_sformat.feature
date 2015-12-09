Feature: sformat

  Builtins.sformat results in a nice value that even if the input is ugly!
  Well, it does return nil if the format argument is nil, but
  that can be checked, and mostly we will see string literal formats.

  Scenario: translates `Ops.add` of a literal and a regular sformat
    Given the original code is
      """
      Ops.add("nice", Builtins.sformat("%1", nil))
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      "nice" + Builtins.sformat("%1", nil)
      """

  Scenario: doesn't translate `Ops.add` of a literal and a ugly sformat
    Given the original code is
      """
      Ops.add("nice", Builtins.sformat(ugly, nil))
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged
