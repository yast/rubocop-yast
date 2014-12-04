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

# replaced code
# rubocop:disable Style/AlignHash
CORRECTED_BUILTINS = {
  # simple logging (outside class)
  "Builtins.y2milestone('foo')" => "include Yast::Logger\nlog.info 'foo'",
  "Builtins.y2milestone('foo')\nBuiltins.y2milestone('foo')" =>
    "include Yast::Logger\nlog.info 'foo'\nlog.info 'foo'",
  "Builtins.y2milestone('foo: %1', foo)" =>
    "include Yast::Logger\nlog.info 'foo: \#{foo}'",
  "Builtins.y2milestone('foo: %1%%', foo)" =>
    "include Yast::Logger\nlog.info 'foo: \#{foo}%'",
  "Builtins.y2warning('%1 %1', foo)" =>
    "include Yast::Logger\nlog.warn '\#{foo} \#{foo}'",
  "Builtins.y2warning('%2 %2', foo, bar)" =>
    "include Yast::Logger\nlog.warn '\#{bar} \#{bar}'",
  "Builtins.y2warning('%2 %1', foo, bar)" =>
    "include Yast::Logger\nlog.warn '\#{bar} \#{foo}'",
  "Builtins.y2warning('%1', foo + bar)" =>
    "include Yast::Logger\nlog.warn '\#{foo + bar}'",

  # complex logging (inside a class)
  "class Foo\n  Builtins.y2error('foo')\nend" =>
    "class Foo\n  include Yast::Logger\n\n  log.error 'foo'\nend",
  "  class Foo\n    Builtins.y2error('foo')\n  end" =>
    "  class Foo\n    include Yast::Logger\n\n    log.error 'foo'\n  end",
  "class Foo\n  include Yast::Logger\n  Builtins.y2error('foo')\nend" =>
    "class Foo\n  include Yast::Logger\n  log.error 'foo'\nend",
  "class Foo < Bar\n  Builtins.y2error('foo')\nend" =>
    "class Foo < Bar\n  include Yast::Logger\n\n  log.error 'foo'\nend",

  # some general builtins
  "Builtins.time()"          => "::Time.now.to_i",
  "Builtins.getenv(\"foo\")" => "ENV[\"foo\"]",
  "Builtins.getenv(foo)"     => "ENV[foo]"
}
# rubocop:enable Style/AlignHash

# kept code, no changes possible
UNCHANGED_BUILTINS = [
  'Builtins.y2milestone(-1, "foo")',
  'Builtins.y2warning(-2, "foo")'
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
    CORRECTED_BUILTINS.each do |old, new|
      it "auto-corrects #{old.gsub("\n", "; ")} => #{new.gsub("\n", "; ")}" do
        expect(autocorrect_source(cop, old.dup)).to eq(new)
      end
    end

    UNCHANGED_BUILTINS.each do |code|
      it "does not auto-corrects #{code}" do
        expect(autocorrect_source(cop, code)).to eq(code)
      end
    end
  end
end
