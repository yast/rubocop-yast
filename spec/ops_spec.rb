# encoding: utf-8

require "spec_helper"

describe RuboCop::Cop::Yast::Ops do
  context("In safe mode") do
    let(:config) do
      conf = { "Yast/Ops" => { "SafeMode" => true } }
      RuboCop::Config.new(conf)
    end

    subject(:cop) { described_class.new(config) }

    it "finds trivial Ops.add call" do
      inspect_source(cop, ["Ops.add(2, 4)"])

      expect(cop.offenses.size).to eq(1)
    end

    it "finds Ops.add call with variable" do
      inspect_source(cop, ["foo = 2\n Ops.add(foo, 4)"])

      expect(cop.offenses.size).to eq(1)
    end

    it "finds Ops.add call with variable inside condition" do
      inspect_source(cop, ["foo = 1\nif true\nOps.add(foo, 4)\nend"])

      expect(cop.offenses.size).to eq(1)
    end

    it "ignores unsafe calls" do
      inspect_source(cop, ["if true\nOps.add(foo, 4)\nend"])

      expect(cop.offenses).to be_empty
    end

    # check that all node types are handled properly
    it "parses complex code" do
      src = <<-EOF
      module Foo
        class Bar
          def baz(arg)
            case arg
            when :foo
              a &&= true
              b ||= true
            end
          rescue e
            while false
              find.foo do
              end
              retry
            end
          ensure
            sure
          end
          class << foo
          end
          def self.foo
          end
        end
      end
      EOF

      inspect_source(cop, src)

      expect(cop.offenses).to be_empty
    end

    it "auto-corrects Ops.add(2, 4) with 2 + 4" do
      new_source = autocorrect_source(cop, "Ops.add(2, 4)")
      expect(new_source).to eq("2 + 4")
    end

    it "auto-corrects Ops.add(a, b) with a + b" do
      new_source = autocorrect_source(cop, "a = 1; b = 2; Ops.add(a, b)")
      expect(new_source).to eq("a = 1; b = 2; a + b")
    end

    it 'auto-corrects Ops.add("foo", "bar") with "foo" + "bar"' do
      new_source = autocorrect_source(cop, 'Ops.add("foo", "bar")')
      expect(new_source).to eq('"foo" + "bar"')
    end

    # FIXME: auto-correct does not work work recursively
    xit "auto-corrects nested Ops.add calls" do
      new_source = autocorrect_source(cop,
        'Ops.add("foo", Ops.add("bar", "baz"))')
      expect(new_source).to eq('"foo" + "bar + baz"')
    end

    it "keeps unsafe call Ops.add(foo, bar)" do
      source = "foo = 1; Ops.add(foo, bar)"
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(source)
    end
  end

  context("In unsafe mode") do
    let(:config) do
      conf = { "Yast/Ops" => { "SafeMode" => false } }
      RuboCop::Config.new(conf)
    end

    subject(:cop) { described_class.new(config) }

    it "finds unsafe Ops.add calls" do
      inspect_source(cop, ["if true\nOps.add(foo, 4)\nend"])

      expect(cop.offenses.size).to eq(1)
    end

    it "auto-corrects unsafe call Ops.add(foo, bar) with foo + bar" do
      new_source = autocorrect_source(cop, "Ops.add(foo, bar)")
      expect(new_source).to eq("foo + bar")
    end
  end
end
