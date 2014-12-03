# encoding: utf-8

require "spec_helper"

def expect_y2milestone_offense(cop)
  expect(cop.offenses.size).to eq(1)
  expect(cop.offenses.first.line).to eq(1)
  expect(cop.messages).to eq(["Builtin call `y2milestone` is obsolete, " \
        "use native Ruby function instead."])
end

describe RuboCop::Cop::Yast::Builtins do
  subject(:cop) { described_class.new }

  it "reports Builtins.* calls" do
    inspect_source(cop, ['Builtins.y2milestone("foo")'])

    expect_y2milestone_offense(cop)
  end

  it "reports Yast::Builtins.* calls" do
    inspect_source(cop, ['Yast::Builtins.y2milestone("foo")'])

    expect_y2milestone_offense(cop)
  end

  it "reports ::Yast::Builtins.* calls" do
    inspect_source(cop, ['::Yast::Builtins.y2milestone("foo")'])

    expect_y2milestone_offense(cop)
  end

  it "ignores lsort builtin" do
    inspect_source(cop, ['Builtins.lsort(["foo"])'])

    expect(cop.offenses).to be_empty
  end

  it "ignores ::Builtins calls" do
    inspect_source(cop, ['::Builtins.y2milestone("foo")'])

    expect(cop.offenses).to be_empty
  end

  it "ignores Foo::Builtins calls" do
    inspect_source(cop, ['Foo::Builtins.y2milestone("foo")'])

    expect(cop.offenses).to be_empty
  end

  it "auto-corrects Builtins.time with ::Time.now.to_i" do
    new_source = autocorrect_source(cop, "Builtins.time")
    expect(new_source).to eq("::Time.now.to_i")
  end

  it 'auto-corrects Builtins.getenv("foo") with ENV["foo"]' do
    new_source = autocorrect_source(cop, 'Builtins.getenv("foo")')
    expect(new_source).to eq('ENV["foo"]')
  end

  it "auto-corrects Builtins.getenv(foo) with ENV[foo]" do
    new_source = autocorrect_source(cop, "Builtins.getenv(foo)")
    expect(new_source).to eq("ENV[foo]")
  end
end
