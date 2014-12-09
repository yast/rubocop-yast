# encoding: utf-8

require "spec_helper"


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

describe RuboCop::Cop::Yast::Builtins do
  let(:config) do
    conf = { "Style/IndentationWidth" => { "Width" => 2 } }
    RuboCop::Config.new(conf)
  end

  subject(:cop) { described_class.new(config) }

  context "Code scanning" do

    IGNORED_BUILTINS.each do |code|
      it "ignores #{code} call" do
        inspect_source(cop, [code])

        expect(cop.offenses).to be_empty
      end
    end
  end
end
