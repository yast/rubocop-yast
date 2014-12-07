
require "rubocop/cop/cop"

# generic class for handling Yast builtins
class BuiltinCall
  attr_reader :safe_mode

  # white list of allowed Builtins calls
  ALLOWED_FUNCTIONS = [
    # locale dependent sorting in not available in Ruby stdlib
    :lsort,
    # gettext helpers
    :dgettext,
    :dngettext,
    :dpgettext,
    # crypt* helpers
    :crypt,
    :cryptmd5,
    :cryptblowfish,
    :cryptsha256,
    :cryptsha512
  ]

  def initialize(safe_mode)
    @safe_mode = safe_mode
  end

  def offense?(node)
    _receiver, method_name, *_args = *node
    !ALLOWED_FUNCTIONS.include?(method_name)
  end

  def correctable?(_node)
    false
  end

  def correction(_node, _corrector)
    raise RuboCop::Cop::CorrectionNotPossible
  end
end

class GetenvCall < BuiltinCall
  def correction(node, corrector)
    lambda do |corrector|
      _builtins, _message, *args = *node
      new_code = "ENV[#{args.first.loc.expression.source}]"
      corrector.replace(node.loc.expression, new_code)
    end
  end
end

class TimeCall < BuiltinCall
  def correction(node, corrector)
    lambda do |corrector|
      new_code = "::Time.now.to_i"
      corrector.replace(node.loc.expression, new_code)
    end
  end
end

class Y2logCall < BuiltinCall
  
end

class Y2debugCall < Y2logCall; end
class Y2milestoneCall < Y2logCall; end
class Y2warningCall < Y2logCall; end
class Y2errorCall < Y2logCall; end
class Y2securityCall < Y2logCall; end
class Y2internalCall < Y2logCall; end
