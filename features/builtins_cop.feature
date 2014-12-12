Feature: Generic Builtins detection and replacement

  Some Builtin calls are not detected as an offense and are kept unchanged.
  That include the calls which do not have native ruby replacement, like lsort()
  or crytp() functions, or the replacement would be too complex (the gettext
  builtins).

  Only known builtins can be replaced, the rest needs to be kept untouched.


  Scenario: y2milestone() builtin call is reported as an offense
    Given the original code is
      """
      Builtins.y2milestone("foo")
      """
    When I check it using RuboCop::Cop::Yast::Builtins cop
    Then offense "Builtin call `y2milestone` is obsolete" is found

  Scenario: Builtin with explicit Yast namespace is reported as an offense
    Given the original code is
      """
      Yast::Builtins.y2milestone("foo")
      """
    When I check it using RuboCop::Cop::Yast::Builtins cop
    Then offense "Builtin call `y2milestone` is obsolete" is found

  Scenario: Builtin with explicit ::Yast namespace is reported as an offense
    Given the original code is
      """
      ::Yast::Builtins.y2milestone("foo")
      """
    When I check it using RuboCop::Cop::Yast::Builtins cop
    Then offense "Builtin call `y2milestone` is obsolete" is found

  Scenario: Builtins with ::Builtins name space are ignored
    Given the original code is
      """
      ::Builtins.y2milestone("foo")
      """
    When I check it using RuboCop::Cop::Yast::Builtins cop
    Then the code is found correct

  Scenario: Builtins in non Yast name space are ignored
    Given the original code is
      """
      Foo::Builtins.y2milestone("foo")
      """
    When I check it using RuboCop::Cop::Yast::Builtins cop
    Then the code is found correct

  Scenario: lsort(), crypt and gettext builtins are allowed
    Given the original code is
      """
      Builtins.lsort(["foo"])
      Builtins.crypt("foo")
      Builtins.dgettext("domain", "foo")
      """
    When I check it using RuboCop::Cop::Yast::Builtins cop
    Then the code is found correct

  Scenario: Unknown builtins are kept unchanged
    Given the original code is
      """
      Builtins.foo()
      """
    When I correct it using RuboCop::Cop::Yast::Builtins cop
    Then the code is unchanged
