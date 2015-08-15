module Story
  module AttributeValidationMixin
    module ClassMixin
      attr_accessor :validation_scopes

      # Declare an external validation scope for use in this class.
      #
      # The scope will be lazy-loaded at runtime and is available
      # using the `#validation_scopes` property of the class.
      #
      # @param [Symbol] name The name of the external scope.
      def validation_scope( name )
        self.validation_scopes ||= {}
        return if self.validation_scopes.has_key? name

        validation_root_path = Dir.resource('model/validation.yml')
        return nil if validation_root_path.nil?

        # lazy load the scope only if it's actually accessed
        self.validation_scopes[name] = Proc.new do
          validation_root = YAML.load(File.read(Dir.resource('model/validation.yml'))).symbolicate

          unless validation_root.nil?
            if validation_root.has_key? name
              # symbolicate all keys, replace :as with Symbols and :type with classes
              scope = Hash.symbolicate(validation_root[name])
              scope = Hash[scope.map do |k, v|
                v[:as]   = v[:as].to_sym              if v.has_key? :as
                v[:type] = Kernel.const_get(v[:type]) if v.has_key? :type
                [k, v]
              end]
              self.validation_scopes[name] = scope
              scope
            end
          end
        end
      end
    end

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
    # @param [Hash] attributes A +Hash+ of attributes to be validated.
    # @param [Hash] expected A hash with validation instructions.
    #   If a +Symbol+ is passed instead of a +Hash+ and a matching scope was
    #   registered using +#validation_scope+ then this scope will be used.
    # @return [Hash] A new hash with validated, augmented attributes or +nil+
    def validate_attributes( attributes, expected )
      @validation_errors ||= []

      if expected.is_a? Symbol
        scope_name = expected.to_sym
        expected = self.class.validation_scopes[scope_name]
        expected = expected.call if expected.is_a? Proc

        if expected.nil?
          @validation_errors << "Undefined validation scope '#{scope_name}'"
          return nil
        end
      end

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

        # optional type-class validation
        if v[:type].is_a? Class
          unless res[k].is_a? v[:type]
            @validation_errors << "Type mismatch: attribute '#{k}' has type '#{res[k].class}' but should be a '#{v[:type]}'"
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

    def self.included( base )
      base.extend(Story::AttributeValidationMixin::ClassMixin)
    end
  end
end

