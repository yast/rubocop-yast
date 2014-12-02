# encoding: utf-8

require "spec_helper"

describe RuboCop::Cop::Yast::Builtins do
  subject(:cop) { described_class.new }

  it "reports Builtins.* call" do
    inspect_source(cop, ['Builtins.y2milestone("foo")'])

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.first.line).to eq(1)
    expect(cop.messages).to eq(["Builtin call `y2milestone` is obsolete, " \
      "use native Ruby function instead."])
  end

  it "ignores lsort builtin" do
    inspect_source(cop, ['Builtins.lsort(["foo"])'])

    expect(cop.offenses).to be_empty
  end

end
