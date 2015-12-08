Feature: loops

  `while` and its negated twin `until` are loops
  which means assignments later in its body can affect values
  earlier in its body and in the condition. Therefore we cannot process either
  one and we must clear the state afterwards.

  `for` loops are just syntax sugar for an `each` call with a block. Thus, we need
  to treat them as blocks.

  Scenario: does not translate anything in the outer scope that contains a `while`
    Given the original code is
      """
      v = 1
      while Ops.add(v, 1)
        Ops.add(1, 1)
      end
      Ops.add(v, 1)
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

  Scenario: does not translate anything in the outer scope that contains an `until`
    Given the original code is
      """
      v = 1
      until Ops.add(v, 1)
        Ops.add(1, 1)
      end
      Ops.add(v, 1)
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

  Scenario: can continue processing after a `while`
    Given the original code is
      """
      while cond
        foo
      end
      v = 1
      Ops.add(v, 1)
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      while cond
        foo
      end
      v = 1
      v + 1
      """

  Scenario: can continue processing after an `until`
    Given the original code is
      """
      until cond
        foo
      end
      v = 1
      Ops.add(v, 1)
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      until cond
        foo
      end
      v = 1
      v + 1
      """

  Scenario: can parse both the syntactic and semantic post-condition
    Given the original code is
      """
      body_runs_after_condition while cond
      body_runs_after_condition until cond

      begin
        body_runs_before_condition
      end while cond

      begin
        body_runs_before_condition
      end until cond
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

  Scenario: does not translate inside a `for` and resumes with a clean slate
    Given the original code is
      """
      v = 1
      v = Ops.add(v, 1)

      for i in [1, 2, 3]
        v = Ops.add(v, 1)
        v = uglify
      end

      v = Ops.add(v, 1)
      w = 1
      w = Ops.add(w, 1)
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      v = 1
      v = v + 1

      for i in [1, 2, 3]
        v = Ops.add(v, 1)
        v = uglify
      end

      v = Ops.add(v, 1)
      w = 1
      w = w + 1
      """
