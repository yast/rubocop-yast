Feature: blocks

  Inside a block the data flow is more complex than we handle now.
  After it, we start anew.

  Scenario: does not translate inside a block and resumes with a clean slate
    Given the original code is
      """
      v = 1
      v = Ops.add(v, 1)

      2.times do
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

      2.times do
        v = Ops.add(v, 1)
        v = uglify
      end

      v = Ops.add(v, 1)
      w = 1
      w = w + 1
      """
