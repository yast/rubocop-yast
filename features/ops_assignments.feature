Feature: assignments

  Scenario: manages niceness correctly in presence of `&&=`
    Given the original code is
      """
      nice1 = true
      nice2 = true
      ugly1 = nil
      ugly2 = nil

      nice1 &&= true
      nice2 &&= nil
      ugly1 &&= true
      ugly2 &&= nil

      Ops.add(nice1, 1)
      Ops.add(nice2, 1)
      Ops.add(ugly1, 1)
      Ops.add(ugly2, 1)
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      nice1 = true
      nice2 = true
      ugly1 = nil
      ugly2 = nil

      nice1 &&= true
      nice2 &&= nil
      ugly1 &&= true
      ugly2 &&= nil

      nice1 + 1
      Ops.add(nice2, 1)
      Ops.add(ugly1, 1)
      Ops.add(ugly2, 1)
      """

  Scenario: manages niceness correctly in presence of `||=`
    Given the original code is
      """
      nice1 = true
      nice2 = true
      ugly1 = nil
      ugly2 = nil

      nice1 ||= true
      nice2 ||= nil
      ugly1 ||= true
      ugly2 ||= nil

      Ops.add(nice1, 1)
      Ops.add(nice2, 1)
      Ops.add(ugly1, 1)
      Ops.add(ugly2, 1)
      """
    When the cop Yast/Ops autocorrects it
    Then the code is converted to
      """
      nice1 = true
      nice2 = true
      ugly1 = nil
      ugly2 = nil

      nice1 ||= true
      nice2 ||= nil
      ugly1 ||= true
      ugly2 ||= nil

      nice1 + 1
      nice2 + 1
      ugly1 + 1
      Ops.add(ugly2, 1)
      """
