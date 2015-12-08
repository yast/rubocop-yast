require "logger"

module RuboCop
  # Yast specific helpers
  module Yast
    def logger
      return @logger if @logger

      @logger = ::Logger.new(STDERR)
      @logger.level = ::Logger::WARN
      @logger.level = ::Logger::DEBUG if $DEBUG
      @logger
    end
    module_function :logger

    def backtrace(skip_frames: 0)
      c = caller
      lines = []
      c.reverse.drop(skip_frames).each_with_index do |frame, i|
        lines << "#{i}: #{frame}"
      end
      lines.reverse_each do |l|
        puts l
      end
    end
    module_function :backtrace
  end
end
