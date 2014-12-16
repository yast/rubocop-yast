Feature: `log` variable detection

  Local variable `log` cannot be safely used together with the Yast Logger.

  Code like `log = "foo"` would overwrite the logger and the subsequent
  logger calls like `log.info "bar"` would crash.

  Scenario: local variable `log` assignment is reported as an offense
    Given the original code is
      """
      log = 1
      """
    When the cop Yast/LogVariable checks it
    Then offense "Do not use `log` variable" is found

  Scenario: assignment via ||= operator is reported as an offense
    Given the original code is
      """
      log ||= true
      """
    When the cop Yast/LogVariable checks it
    Then offense "Do not use `log` variable" is found

  Scenario: assignment via &&= operator is reported as an offense
    Given the original code is
      """
      log &&= true
      """
    When the cop Yast/LogVariable checks it
    Then offense "Do not use `log` variable" is found

  Scenario: `log` variable is found also in multiple assignment
    Given the original code is
      """
      log, foo, bar = baz()
      """
    When the cop Yast/LogVariable checks it
    Then offense "Do not use `log` variable" is found

  Scenario: using `@log` instance variable is allowed
    Given the original code is
      """
      @log = true
      """
    When the cop Yast/LogVariable checks it
    Then the code is found correct

  Scenario: using `@@log` class variable is allowed
    Given the original code is
      """
      @@log = true
      """
    When the cop Yast/LogVariable checks it
    Then the code is found correct

  Scenario: using `$log` global variable is allowed
    Given the original code is
      """
      $log = true
      """
    When the cop Yast/LogVariable checks it
    Then the code is found correct
