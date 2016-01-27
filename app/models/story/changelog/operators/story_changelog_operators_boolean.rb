module Story
  module Changelog::Operators
    # 'Always true' operator
    class True
      # Execute the operator
      # This operator will ignore any arguments and always returns +true+.
      # @return [Boolean] Always +true+
      def eval( _, _ )
        true
      end
    end

    # 'Always false' operator
    class False
      # Execute the operator.
      # This operator will ignore any arguments and always returns +false+.
      # @return [Boolean] Always +false+
      def eval( _, _ )
        false
      end
    end
  end
end
