Feature: case

  With a **single-pass top-down data flow analysis**, that we have been using,
  we can process the `case` statement but not beyond it,
  because we cannot know which branch was taken.

  We can proceed after the `case` statement but must **start with a clean slate**.
  More precisely we should remove knowledge of all variables affected in either
  branch of the `case` statement, but we will first simplify the job and wipe all
  state for the processed method.

  Scenario: translates the `when` body of a `case` statement
    Given the original code is
      """
      case expr
        when 1
          Ops.add(1, 1)
      end
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      case expr
        when 1
          1 + 1
      end
      """

  Scenario: It translates all branches of a `case` statement, independently of each other
    Given the original code is
      """
      v = 1
      case expr
        when 1
          Ops.add(v, 1)
          v = nil
        when 2
          Ops.add(v, 2)
          v = nil
        else
          Ops.add(1, v)
          v = nil
      end
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      v = 1
      case expr
        when 1
          v + 1
          v = nil
        when 2
          v + 2
          v = nil
        else
          1 + v
          v = nil
      end
      """

  Scenario: The expression also contributes to the data state
    Given the original code is
      """
      case v = 1
        when 1
          Ops.add(v, 1)
      end
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      case v = 1
        when 1
          v + 1
      end
      """

  Scenario: The test also contributes to the data state
    Given the original code is
      """
      case expr
        when v = 1
          Ops.add(v, 1)
      end
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      case expr
        when v = 1
          v + 1
      end
      """

  Scenario: The test also contributes to the data state
    Given the original code is
      """
      v = 1
      case expr
        when 1
          v = nil
      end
      Ops.add(v, 1)
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

  Scenario: It translates zombies whose arguments were found nice after a `case`
    Given the original code is
      """
      case expr
        when 1
          v = nil
      end
      v = 1
      Ops.add(v, 1)
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      case expr
        when 1
          v = nil
      end
      v = 1
      v + 1
      """
