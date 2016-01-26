Feature: exceptions

  Raising an exception is not a problem at the `raise` site. There it means
  that all remaining code in a `def` is skipped. It is a problem at the `rescue`
  or `ensure` site where it means that *some* of the preceding code was not
  executed.

  The `retry` statement makes the begin-body effectively a loop which limits
  our translation possibilities.

  Scenario: translates the parts, joining else, rescue separately
    Given the original code is
      """
      def foo
        v = 1
        Ops.add(v, 1)
      rescue
        w = 1
        Ops.add(w, 1)
        v = nil
      rescue
        Ops.add(w, 1)
      else
        Ops.add(v, 1)
      end
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      def foo
        v = 1
        v + 1
      rescue
        w = 1
        w + 1
        v = nil
      rescue
        Ops.add(w, 1)
      else
        v + 1
      end
      """

  Scenario: does not translate code that depends on niceness skipped via an exception
    Given the original code is
      """
      def a_problem
        v = nil
        w = 1 / 0
        v = 1
      rescue
        puts "Oops", Ops.add(v, 1)
      end
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

  Scenario: can parse the syntactic variants of exception handling
    Given the original code is
      """
      begin
        foo
        raise "LOL"
        foo
      rescue Error
        foo
      rescue Bug, Blunder => b
        foo
      rescue => e
        foo
      rescue
        foo
      ensure
        foo
      end
      yast rescue nil
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged

  Scenario: does not translate a begin-body when a rescue contains a retry
    Given the original code is
      """
      def foo
        v = 1
        begin
          Ops.add(v, 1)
          maybe_raise
        rescue
          v = nil
          retry if cond
        end
      end
      """
    When the cop Yast/Ops autocorrects it
    Then the code is unchanged
