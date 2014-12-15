Feature: Builtins.time()

  Builtins.time() call can be easily replaced by native Time.now call.
  It has no parameter therefore no extra handling is needed.


  Scenario: Builtins.time() is replaced by ::Time.now.to_i
    Given the original code is "Builtins.time()"
    When the cop Yast/Builtins autocorrects it
    Then the code is converted to "::Time.now.to_i"
