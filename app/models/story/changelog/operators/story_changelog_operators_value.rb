module Story
  module Changelog::Operators
    class Value
      # Create a new Value operator instance
      #
      # @param [String] op The desired operation, one of:
      #   '==', '~=', '/=', '<=', '>=', '<' or '>'
      # @param [String] prop The object property to query.
      #   Special value: '$value' to access the objects value,
      #   Special value: '$length' to access an arrays length
      # @param [Object] value The value used to compare against
      def initialize( op, prop, value )
        if %w(== ~= /= <= >= < >).include? op
          @op = op
        else
          # FIXME: report this
          @op = '=='
        end

        @prop = prop
        @value = value
      end

      # Execute the operator.
      # This method will execute the operator and carry out the
      # selected comparison between +prop+ and +value+ as specified
      # when the operator was created.
      #
      # @prop [Story::Changelog::ValueMapper] mapper A +ValueMapper+ instance
      # @prop [String] obj_path The story path of the object or object property
      #   being evaluated.
      # @return [Boolean] +true+ or +false+ depending on the outcome of the
      #   operation.
      def eval( mapper, obj_path )
        if obj_path.end_with? ']'
          # working directly on an object
          lp "#{self}: fetching property value for object.."
          prop_val = mapper.get_value("#{obj_path}:#{@prop}")
          lp "#{self}: prop_val => '#{prop_val}'"
        else
          # working on an objects properties
          case @prop
          when '$value'
            lp "#{self}: fetching $value of property.."
            prop_val = mapper.get_value(obj_path)
          when '$length'
            v = mapper.get_value(obj_path)
            if v.is_a? Array
              lp "#{self}: fetching $length of array.."
              prop_val = v.length
            else
              lp "#{self}: object is not an array, no length"
              prop_val = 0
            end
          else
            lp "#{self}: using original prop_val"
            prop_val = @prop
          end
          lp "#{self}: prop_val => '#{prop_val}'"
        end

        return false unless op_is_valid_for_type? prop_val

        lp "#{self}: executing op '#{@op}' (#{prop_val}, #{prop_val.class} / #{@value}, #{@value.class})"
        case @op
        when '=='
          prop_val == @value
        when '/='
          prop_val != @value
        when '<='
          prop_val <= @value
        when '>='
          prop_val >= @value
        when '<'
          prop_val < @value
        when '>'
          prop_val > @value
        when '~='
          ! Regexp.new(@value).match(prop_val).nil?
        else
          false
        end
      end

      # @private
      def to_s
        "<Operators::Value '#{@prop}' '#{@op}' '#{@value}'>"
      end

      private

      # Check if the selected operation is valid for the value type
      # of +prop_val+.
      #
      # @param [Object] prop_val The property value to be evaluated.
      #   This method will check it's class to validate the operation.
      # @return [Boolean] +true+ if the operation is supported, +false+ if not.
      def op_is_valid_for_type?( prop_val )
        lp "#{self}: checking for valid ops on #{prop_val.class}"
        if prop_val.is_a? String
          %w(== /= ~=).include? @op
        elsif (prop_val.is_a? Fixnum or prop_val.is_a? Float)
          %w(== /= <= >= < >).include? @op
        elsif prop_val.is_a? TrueClass or prop_val.is_a? FalseClass
          %w(== /=).include? @op
        else
          false
        end
      end
    end
  end
end
