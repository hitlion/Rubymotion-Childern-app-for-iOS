module Story
  module Changelog::Operators
    # Basic AND and OR logic operator
    class Logic
      # Create a now +Logic+ instance.
      #
      # @param [String] op 'and' or 'or'
      # @param [Array] args An +Array+ of other operators to evaluate.
      def initialize( op, *args )
        @op   = op || 'and'
        @args = args || [ True.new, True.new ]
      end

      # Execute the operator
      # This method will execute the operator, depending on the choosen
      # operation, will either do a logic AND or logic OR link of all
      # sub-operators passed in when creating this operator.
      # Both supported operations follow the shortuct rule:
      # - AND will return +false+ once the first sub-operator returns +false+
      # - OR will return +true+ once the first sub-operator returns +true+
      #
      # @param [Story::Changelog::ValueMapper] mapper A +ValueMapper+ instance
      # @param [String] obj The path to the story object being evaluated
      # @return [Boolean] +true+ if the operation succeeded, +false+ otherwise.
      def eval( mapper, obj )
        case @op
          when 'or'
            @args.each { |arg| return true if arg.eval( mapper, obj ) }
            false
          when 'and'
            @args.each { |arg| return false unless arg.eval( mapper, obj ) }
            true
          else
            false
        end
      end

      # @private
      def to_s
        "<Operators::Logic '#{@op}' '#{@args.join("\n  ")}'>"
      end
    end
  end
end
