# encoding: utf-8

require "spec_helper"

# these calls are found by the cop
REPORTED_BUILTINS = [
  'Builtins.y2milestone("foo")',
  # explicit Yast namespace
  'Yast::Builtins.y2milestone("foo")',
  '::Yast::Builtins.y2milestone("foo")'
]

# these are not reported: invalid or are allowed to use
IGNORED_BUILTINS = [
  # not in the Yast namespace
  '::Builtins.y2milestone("foo")',
  'Foo::Builtins.y2milestone("foo")',
  # these do not have support in std Ruby
  'Builtins.lsort(["foo"])',
  'Builtins.crypt("foo")',
  'Builtins.dgettext("domain", "foo")'
]

# kept code, no changes possible
UNCHANGED_BUILTINS = [
  # an unknown builtin
  'Builtins.foo("bar")'
]

describe RuboCop::Cop::Yast::Builtins do
  let(:config) do
    conf = { "Style/IndentationWidth" => { "Width" => 2 } }
    RuboCop::Config.new(conf)
  end

  subject(:cop) { described_class.new(config) }

  context "Code scanning" do
    REPORTED_BUILTINS.each do |code|
      it "reports #{code} calls" do
        inspect_source(cop, [code])

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line).to eq(1)
        expect(cop.messages.first).to match(/Builtin call `.*` is obsolete/)
      end
    end

    IGNORED_BUILTINS.each do |code|
      it "ignores #{code} call" do
        inspect_source(cop, [code])

        expect(cop.offenses).to be_empty
      end
    end
  end

  context "Code autocorrection" do

    UNCHANGED_BUILTINS.each do |code|
      it "does not auto-corrects #{code}" do
        expect(autocorrect_source(cop, code)).to eq(code)
      end
    end
  end
end
