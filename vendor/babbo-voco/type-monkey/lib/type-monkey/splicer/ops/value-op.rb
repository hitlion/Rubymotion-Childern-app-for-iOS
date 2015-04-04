unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/splicer/ops'
end

module TypeMonkey
  module Splicer
    module Ops
      # A value checking operator
      class ValueOp
        # Setup a new +ValueOp+ instance
        # @param op [String] any of the supported operations 
        #   "==, ~=, /=, <=, >=, <, >".
        # @param prop [String] the name of the property this +ValueOp+ should
        #   check against.
        # @param value [Object] Either an +Fixnum+, +String+, +Float+ or
        #  +Boolean+ with the expected value.
        def initialize( op, prop, value )
          unless %w(== ~= /= <= >= < >).include? op
            raise Ops::Error, "Undefined value operation '#{op}'."
          end

          @op = op
          @prop = prop
          @value = value
        end

        # Evaluate this +ValueOp+.
        # This will call +properties+ on +object+, check if the required
        # property is available and then use the operation passed to
        # +ValueOp#new+ to compare against the required value.
        # @param object [CoreSplicer] A +CoreSplicer+ based object used to
        #   query its properties and their values.
        # @return [TrueClass] If the object has the required property and value.
        # @return [FalseClass] If the object didn't match the criteria.
        def eval( object )
          if supported_for? @value
            prop = object.properties[@prop]
            case @op
              when '=='
                prop == @value
              when '/='
                prop != @value
              when '<='
                prop <= @value
              when '>='
                prop >= @value
              when '<'
                prop < @value
              when '>'
                prop > @value
              when '~='
                ! Regexp.new( @value ).match( prop ).nil?
              else
                false
            end
          else
            raise Ops::Error, "Unsupported value operation '#{@op}' on type '#{@value.class}'."
          end
        end

        private

        # @private
        # Check if the require comparison is supported on +object+.
        # This will for example reject regexp checking against +Fixnum+.
        def supported_for?( object )
          if object.is_a? String
            %w(== /= ~=).include? @op
          elsif ( object.is_a? Fixnum or object.is_a? Float )
            %w(== /= <= >= < >).include? @op
          elsif object.is_a? Boolean
            %w(== /=).include? @op
          else
            false
          end
        end
      end
    end
  end
end

