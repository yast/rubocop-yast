# encoding: utf-8

require "spec_helper"

describe RuboCop::Cop::Yast::Ops do
  subject(:cop) { described_class.new }

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

  it "finds Ops.add call which cannot be safely replaced" do
    inspect_source(cop, ["if true\nOps.add(foo, 4)\nend"])

    expect(cop.offenses.size).to eq(1)
  end

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

end
