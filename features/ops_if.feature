Feature: if

  With a **single-pass top-down data flow analysis**, that we have been using,
  we can process the `if` statement but not beyond it,
  because we cannot know which branch was taken.

  We can proceed after the `if` statement but must **start with a clean slate**.
  More precisely we should remove knowledge of all variables affected in either
  branch of the `if` statement, but we will first simplify the job and wipe all
  state for the processed method.

  Scenario: translates the `then` body of an `if` statement
    Given the original code is
      """
      if cond
        Ops.add(1, 1)
      end
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      if cond
        1 + 1
      end
      """

  Scenario: translates the `then` body of an `unless` statement
    Given the original code is
      """
      unless cond
        Ops.add(1, 1)
      end
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      unless cond
        1 + 1
      end
      """

  Scenario: It translates both branches of an `if` statement, independently of each other
    Given the original code is
      """
      v = 1
      if cond
        Ops.add(v, 1)
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
      if cond
        v + 1
        v = nil
      else
        1 + v
        v = nil
      end
      """

  Scenario: The condition also contributes to the data state
    Given the original code is
      """
      if cond(v = 1)
        Ops.add(v, 1)
      end
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      if cond(v = 1)
        v + 1
      end
      """

  Scenario: Niceness invalidated by `if`: Plain `if`
    Given the original code is
      """
      v = 1
      if cond
        v = nil
      end
      Ops.add(v, 1)
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

  Scenario: Niceness invalidated by `if`: Trailing `if`
    Given the original code is
      """
      v = 1
      v = nil if cond
      Ops.add(v, 1)
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

  Scenario: Niceness invalidated by `if`: Plain `unless`
    Given the original code is
      """
      v = 1
      unless cond
        v = nil
      end
      Ops.add(v, 1)
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

  Scenario: Niceness invalidated by `if`: Trailing `unless`
    Given the original code is
      """
      v = 1
      v = nil unless cond
      Ops.add(v, 1)
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

  Scenario: It translates zombies whose arguments were found nice after an `if`
    Given the original code is
      """
      if cond
         v = nil
      end
      v = 1
      Ops.add(v, 1)
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      if cond
         v = nil
      end
      v = 1
      v + 1
      """
