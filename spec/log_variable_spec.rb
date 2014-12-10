# encoding: utf-8

require "spec_helper"

describe RuboCop::Cop::Yast::LogVariable do
  subject(:cop) { described_class.new }

  it "finds log variable assignment" do
    inspect_source(cop, ["log = 1"])

    expect(cop.offenses.size).to eq(1)
    expect(cop.messages.first).to match(/Do not use `log` variable/)
  end

  it "finds log variable assignment via ||=" do
    inspect_source(cop, ["log ||= true"])

    expect(cop.offenses.size).to eq(1)
    expect(cop.messages.first).to match(/Do not use `log` variable/)
  end

  it "finds log variable assignment via &&=" do
    inspect_source(cop, ["log &&= true"])

    expect(cop.offenses.size).to eq(1)
    expect(cop.messages.first).to match(/Do not use `log` variable/)
  end

  it "finds log variable in multiple assignment" do
    inspect_source(cop, ["log, foo, bar = baz()"])

    expect(cop.offenses.size).to eq(1)
    expect(cop.messages.first).to match(/Do not use `log` variable/)
  end

  it "ignores @log instance variable" do
    inspect_source(cop, ["@log = true"])

    expect(cop.offenses).to be_empty
  end

  it "ignores @@log class variable" do
    inspect_source(cop, ["@@log = true"])

    expect(cop.offenses).to be_empty
  end

  it "ignores $log global variable" do
    inspect_source(cop, ["$log = true"])

    expect(cop.offenses).to be_empty
  end
end
