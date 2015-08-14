module Story
  module AttributeValidationMixin
    attr_reader :validation_errors

    # Validate +attributes+ against +expected+ and return a new +Hash+.
    # +excepted+ contains a set of keys and how to validate them in attributes:
    #
    # ``ruby
    # {
    #   :attribute_name => {
    #     :required => true/false, # optional: is thes attribute required?
    #     :default  => object,     # optional: default value if not required
    #     :as       => conversion  # optional: selector to +send()+ to
    #                              # convert the value (e.g. :to_s, :to_i, ..)
    # }
    # ```
    #
    # If +attributes+ is missing an attribute which has its `:required` key set
    # the validation will fail. Otherwise the attribute will be either ignored
    # or - if `:default` was set - be replaced with a default value.
    #
    # If the additional `:as` key is present the specified selector will be
    # +send()+ to the value and the result used. This is handy for in-place
    # string / integer / symbol conversion using :to_s, :to_i and so forth.
    #
    # If validation fails the object property +validation_errors+ will be set.
    # If an optional block is passed it will be called with the validated attributes
    # as single argument.
    #
    # @param [Hash] attributes A hash of attributes to be validated.
    # @param [Hash] expected A hash with validation instructions.
    # @return [Hash] A new hash with validated, augmented attributes or +nil+
    def validate_attributes( attributes, expected )
      @validation_errors = []

      # check unexpected attributes
      attributes.keys.each do |k|
        @validation_errors << "Unexpected attribute '#{k}'" unless expected.has_key? k
      end

      res = {}
      expected.each_pair do |k, v|
        if attributes.has_key? k
          # assign the existing value with optional conversion
          res[k] = v[:as].nil? ? attributes[k] : attributes[k].send(v[:as])
        else
          if v[:required] == true
            @validation_errors << "Missing attribute '#{k}'"
          elsif ! v[:default].nil?
            # assign the default value
            res[k] = v[:as].nil? ? v[:default] : v[:default].send(v[:as])
          end
        end
      end

      if @validation_errors.empty?
        yield res
        res
      else
        nil
      end
    end
  end
end

