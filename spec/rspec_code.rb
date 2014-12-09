
# this module provides code block generators for RSpecRenderer
module RspecCode
  # rubocop:disable Metrics/MethodLength
  def generate_translation_code
    [
      "original_code = code_cleanup(<<-EOT)",
      Code.indent(@original_code),
      "EOT",
      "",
      "translated_code = code_cleanup(<<-EOT)",
      Code.indent(@translated_code),
      "EOT",
      "",
      "cop = RuboCop::Cop::Yast::Builtins.new",
      "expect(autocorrect_source(cop, original_code)).to eq(translated_code)"
    ].join("\n")
  end

  def generate_offense_code
    [
      "code = code_cleanup(<<-EOT)",
      Code.indent(@offense),
      "EOT",
      "",
      "cop = RuboCop::Cop::Yast::Builtins.new",
      "inspect_source(cop, [code])",
      "",
      "expect(cop.offenses.size).to eq(1)",
      "expect(cop.messages.first).to match(/Builtin call `.*` is obsolete/)"
    ].join("\n")
  end

  def generate_accepted_code
    [
      "code = code_cleanup(<<-EOT)",
      Code.indent(@accepted_code),
      "EOT",
      "",
      "cop = RuboCop::Cop::Yast::Builtins.new",
      "inspect_source(cop, [code])",
      "",
      "expect(cop.offenses).to be_empty"
    ].join("\n")
  end
  # rubocop:enable Metrics/MethodLength
end
