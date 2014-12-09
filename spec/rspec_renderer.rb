require "redcarpet"

# require_relative "../lib/rubocop-yast"

# Utility functions for manipulating code.
module Code
  INDENT_STEP = 2

  class << self
    def join(lines)
      lines.map { |l| "#{l}\n" }.join("")
    end

    def indent(s)
      s.gsub(/^(?=.)/, " " * INDENT_STEP)
    end
  end
end

# Represents RSpec's "it" block.
class It
  def initialize(attrs)
    @description = attrs[:description]
    @code        = attrs[:code]
    @skip        = attrs[:skip]
  end

  def render
    [
      "#{@skip ? "xit" : "it"} #{@description.inspect} do",
      Code.indent(@code),
      "end"
    ].join("\n")
  end
end

# Represents RSpec's "describe" block.
class Describe
  attr_reader :blocks

  def initialize(attrs)
    @description = attrs[:description]
    @blocks      = attrs[:blocks]
  end

  def render
    parts = []
    parts << "describe #{@description.inspect} do"
    parts << Code.indent(@blocks.map(&:render).join("\n\n")) if !blocks.empty?
    parts << "end"
    parts.join("\n")
  end
end

# Renders a Markdown file to an RSpec test script
class RSpecRenderer < Redcarpet::Render::Base
  IGNORED_HEADERS = [
    "Table Of Contents",
    "Concepts"
  ]

  def initialize
    super

    @next_block_type = :unknown
    @describe = Describe.new(description: "RuboCop-Yast", blocks: [])
  end

  # preprocess the MarkDown input - remove comments
  def preprocess(fulldoc)
    # use multiline regexp pattern
    fulldoc.gsub(/<!--.*-->/m, "")
  end

  def header(text, header_level)
    return nil if header_level == 1 || IGNORED_HEADERS.include?(text)

    if header_level > describes_depth + 1
      raise "Missing higher level header: #{text}"
    end

    describe_at_level(header_level - 1).blocks << Describe.new(
      description: text + ":",
      blocks:      []
    )

    nil
  end

  def paragraph(text)
    if text =~ /^\*\*(.*)\*\*$/
      @next_block_type = Regexp.last_match[1].downcase.to_sym
    else
      first_sentence = text.split(/\.(\s+|$)/).first
      @description = first_sentence.sub(/^RuboCop-Yast /, "").sub(/\n/, " ")
    end

    nil
  end

  # rubocop:disable Metrics/MethodLength
  def block_code(code, _language)
    case @next_block_type
    when :original
      @original_code = escape(code[0..-2])
    when :translated
      @translated_code = escape(code[0..-2])
    when :unchanged
      @original_code = @translated_code = code[0..-2]
    else
      raise "Invalid next code block type: #{@next_block_type}.\n#{code}"
    end
    @next_block_type = :unknown

    if @original_code && @translated_code
      current_describe.blocks << It.new(
        description: @description,
        code:        generate_translation_code,
        skip:        @description =~ /XFAIL/
      )

      @original_code   = nil
      @translated_code = nil
    end

    nil
  end
  # rubocop:enable Metrics/MethodLength

  # escape ruby interpolation
  def escape(code)
    code.gsub("\#{", "\\\#{")
  end

  def doc_header
    Code.join([
      "# Automatically generated -- DO NOT EDIT!",
      "",
      "require \"spec_helper\"",
      ""
    ])
  end

  def doc_footer
    "#{@describe.render}\n"
  end

  private

  def describes_depth
    describe = @describe
    depth = 1
    while describe.blocks.last.is_a?(Describe)
      describe = describe.blocks.last
      depth += 1
    end
    depth
  end

  def current_describe
    describe = @describe
    describe = describe.blocks.last while describe.blocks.last.is_a?(Describe)
    describe
  end

  def describe_at_level(level)
    describe = @describe
    2.upto(level) do
      describe = describe.blocks.last
    end
    describe
  end

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
  # rubocop:enable Metrics/MethodLength
end
