unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/splicer/ops'
end

module TypeMonkey
  module Splicer
    module Ops
      # Generic logical operator.
      # This class implements the AND and OR logical operations.
      class LogicOp
        def initialize( op, *args )
          unless %w(and or).include? op
            raise Ops::Error, "Undefined logic operation '#{op}'."
          end
          unless args.count >= 2
            raise Ops::Error, 'Logic operations require at least two parameters.'
          end
          @op   = op
          @args = args
        end

        # Evaluate the operation returning either +true+ or +false+.
        # This will - in turn - call +eval()+ on all sub-operators
        # and then either AND or OR them shortcutting as needed.
        # @param obj [CoreSplicer] A +CoreSplicer+ based object used to query properties.
        # @return [TrueClass] If the operation evaluated to +true+.
        # @return [FalseClass] If the evaluation failed.
        def eval( obj )
          if @op == 'or'
            @args.each { |arg| return true if arg.eval( obj ) }
            false
          else
            @args.each { |arg| return false unless arg.eval( obj ) }
            true
          end
        end
      end
    end
  end
end

