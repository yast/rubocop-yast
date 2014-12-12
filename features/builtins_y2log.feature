Feature: Builtins.y2debug(), Builtins.y2milestone(), ...

  The logging builtins can be replaced by a logger call.

  But we need to replace the YCP sformat message by Ruby interpolation
  (otherwise we would introduce a new Builtins.sformat() call and basically
  just replaced one builtin by another).

  The new logger needs extra include call as it is defined in the
  Yast::Logger module. This include is added at the parent class or module
  definition. If there is no parent class or module then it is added at
  the top level.

  Some modules already use (include) the logger, we need to check it's presence
  and add it only when it is missing to avoid duplicates.

  Another possible problem is using a local variable named `log`. The problem
  is that `log = "foo"` code would replace the logger object by a String
  and all subsequent `log.*` calls would fail.

  In that case no logging call is replaced in whole class.


  Scenario: `y2debug` call is changed to `log.debug` call
    Given the original code is
      """
      Builtins.y2debug("foo")
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.debug "foo"
      """

  Scenario: `y2milestone` call is changed to `log.info`
    Given the original code is
      """
      Builtins.y2milestone("foo")
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.info "foo"
      """

  Scenario: `y2warning` call is changed to `log.warn`
    Given the original code is
      """
      Builtins.y2warning("foo")
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.warn "foo"
      """

  Scenario: `y2error` call is changed to `log.error`
    Given the original code is
      """
      Builtins.y2error("foo")
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.error "foo"
      """

  Scenario: `y2security` call is changed to `log.error`
    Given the original code is
      """
      Builtins.y2security("foo")
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.error "foo"
      """

  Scenario: `y2internal` call is changed to `log.fatal`
    Given the original code is
      """
      Builtins.y2internal("foo")
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.fatal "foo"
      """

  Scenario: The include statement is added only once for multiple calls
    Given the original code is
      """
      Builtins.y2milestone("foo")
      Builtins.y2milestone("foo")
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.info "foo"
      log.info "foo"
      """

  Scenario: The YCP sformat message is converted to Ruby interpolation
    Given the original code is
      """
      Builtins.y2milestone("foo: %1", foo)
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.info "foo: #{foo}"
      """

  Scenario: The %% sequence in the format string is changed to simple %
    Given the original code is
      """
      Builtins.y2milestone("foo: %1%%", foo)
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.info "foo: #{foo}%"
      """

  Scenario: The repeated % placeholders are replaced in the format string
    Given the original code is
      """
      Builtins.y2warning("%1 %1", foo)
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.warn "#{foo} #{foo}"
      """

  Scenario: The % placeholders do not need to start from 1
    Given the original code is
      """
      Builtins.y2warning("%2 %2", foo, bar)
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.warn "#{bar} #{bar}"
      """

  Scenario: The % placeholders do not need to be in ascending order
    Given the original code is
      """
      Builtins.y2warning("%2 %1", foo, bar)
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.warn "#{bar} #{foo}"
      """

  Scenario: The original statements in interpolated string are kept
    Given the original code is
      """
      Builtins.y2warning("%1", foo + bar)
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.warn "#{foo + bar}"
      """

  Scenario: A log message containing interpolattion is kept unchanged
    Given the original code is
      """
      Builtins.y2warning("foo: #{foo}")
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.warn "foo: #{foo}"
      """

  Scenario: Log message stored in a variable can be converted as well
    Given the original code is
      """
      msg = "message"
      Builtins.y2warning(msg)
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      msg = "message"
      log.warn msg
      """

  Scenario: Log message returned by function call is converted as well
    Given the original code is
      """
      Builtins.y2warning(msg)
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.warn msg
      """

  Scenario: Log call with variable message and extra parameters is kept unchaged
    Given the original code is
      """
      Builtins.y2warning(msg, arg1, arg2)
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is unchanged

  Scenario: Message with operator call is traslated
    Given the original code is
      """
      Builtins.y2warning(msg1 + msg2)
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.warn msg1 + msg2
      """

  Scenario: The include is added to the class definition
    Given the original code is
      """
      class Foo
        Builtins.y2error('foo')
      end
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      class Foo
        include Yast::Logger

        log.error "foo"
      end
      """

  Scenario: The added include follows parent class indentation
    Given the original code is
      """
        class Foo
          Builtins.y2error('foo')
        end
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
        class Foo
          include Yast::Logger

          log.error "foo"
        end
      """

  Scenario: The logger include is not added if already present
    Given the original code is
      """
      class Foo
        include Yast::Logger
        Builtins.y2error('foo')
      end
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      class Foo
        include Yast::Logger
        log.error "foo"
      end
      """

  Scenario: The logger include is added after the parent class name if present
    Given the original code is
      """
      class Foo < Bar
        Builtins.y2error('foo')
      end
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      class Foo < Bar
        include Yast::Logger

        log.error "foo"
      end
      """

  Scenario: The logger include is added to parent class when used in a method
    Given the original code is
      """
      module Yast
        class TestClass < Module
          def test
            Builtins.y2error("foo")
            Builtins.y2debug("foo")
          end
        end
      end
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      module Yast
        class TestClass < Module
          include Yast::Logger

          def test
            log.error "foo"
            log.debug "foo"
          end
        end
      end
      """

  Scenario: Single quoted format string is converted to double quoted
    Given the original code is
      """
      Builtins.y2milestone('foo: %1', foo)
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.info "foo: #{foo}"
      """

  Scenario: Double quotes and interpolations are escaped when converting a single quoted string
    Given the original code is
      """
      Builtins.y2milestone('"#{foo}"')
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is converted to
      """
      include Yast::Logger
      log.info "\"\#{foo}\""
      """

  Scenario: Logging call with a backtrace is kept unchanged
    Given the original code is
      """
      Builtins.y2milestone(-1, "foo")
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is unchanged

  Scenario: Code with a local variable 'log' is kept unchanged
    Given the original code is
      """
      log = 1
      Builtins.y2milestone("foo")
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is unchanged

  Scenario: Call with missing parenthesis around argument is also reported as an offense
    Given the original code is
      """
      Builtins.y2milestone "Executing hook '#{name}'"
      """
    When I check it using RuboCop::Cop::Yast::Builtins cop
    Then offense "Builtin call `y2milestone` is obsolete" is found

