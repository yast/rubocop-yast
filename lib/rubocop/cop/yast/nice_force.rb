# encoding: utf-8

module RuboCop
  module Cop
    # Investigates Niceness, that is, values not being nil.
    class NiceForce < Force
      # Starting point.
      def investigate(processed_source)
        np = NicenessProcessor.new
        np.process(processed_source.ast)
      end
    end
  end
end

# A simple niceness processor
class NicenessProcessor < Parser::AST::Processor
  include RuboCop::Yast::TrackVariableScope
end
