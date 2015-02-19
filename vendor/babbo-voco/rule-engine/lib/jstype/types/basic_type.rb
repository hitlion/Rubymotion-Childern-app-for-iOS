# +BasicType+ is the base for both simple- and compound types.
# It contains stubs for all methods supported in both type classes and helps
# keep the code and error handling just that little bit cleaner.
# It is also the place where the global type registry is located which is shared
# by all classes based on +BasicType+.
class BasicType
  # Exception class used to report errors (also in all sub classes)
  class TypeError < StandardError; end

  # A helper class used to contain the results of all validations done when
  # calling the +validate+ method.
  class ValidationResult
    attr_accessor :errors, :valid

    def initialize
     @errors = []
      @valid = true
    end
  end

  # A reference to some at this point unknown type.
  # +ForwardReference+ is used to store the referenced type name and is later
  # replaced with a copy of the real type.
  class ForwardReference
    attr_reader :referenced_type

    # Setup a new +ForwardReference+
    # @param [String] type_name The name of the type that should be here..
    def initialize( type_name )
      @referenced_type = type_name
    end

    # Try to resolve this reference to an actual type instance.
    # @return [BasicType] An instance of the referenced type
    # @return [NilClass] If the type can't be resolved
    def resolve
      if BasicType.type_with_name( @referenced_type ).is_a? BasicType
        BasicType.type_with_name( @referenced_type )
      else
        nil
      end
    end
  end

  # Global type registry (per-subclass)
  @type_registry = {}

  class << self
    attr_accessor :type_registry

    # Lookup a type by name.
    # @param [String] name The name of the requested type.
    # @return [BasicType] The type instance if +name+ is a registered type
    # @return [NilClass] Otherwise
    def type_with_name( name )
      BasicType.type_registry[name]
    end

    def rampage!
      BasicType.type_registry.keys.to_a.each do |type|
        obj = BasicType.type_registry[type]
        if obj.class == DerivedSimpleType || obj.class == DerivedCompoundType
          obj.resolve_references
        end
      end
    end

    # prevent direct calls to #new
    protected :new
  end

  # Initialize a new +BasicType+
  # @param [String] type_name The name for the new type class
  # @param [String] type_class The name of an existing class to base this type on
  # @param [String] metaclass The name of an existing class to use as property
  #   meta class for this type.
  def initialize( type_name, type_class, metaclass=nil )
    @type_name = type_name
    @type_class = type_class
    @type_meta = BasicType.type_with_name( metaclass )
  end

  # Return the native ruby class used for this type.
  # If the type is derived the lookup will traverse up the class hierarchy.
  # @return [Class] The native ruby class this type is mapped to
  def type_class
    @type_class || super
  end

  # Return the name this type was registered with.
  # @return [String] The name used to register this type.
  def type_name
    @type_name
  end

  # Return the metatype used for extended properties etc. (if any)
  # @return [BasicType] The metatype class
  def type_meta
    @type_meta
  end

  # Return the pattern used to validate values of this type.
  # @return [Regexp] The +Regexp+ object if a pattern is assigned.
  # @return [NilClass] If validation pattern is assigned.
  def pattern
    raise TypeError, "<#{@type_name}> does not support the 'pattern' attribute."
  end

  # Return the list of valid enumeration values for this type.
  # @return [Array] An array of valid values <if one was set>
  def enum
    raise TypeError, "<#{@type_name}> does not support the 'enum' attribute."
  end

  # Return the min/max range of values valid for this type.
  # @return [Array] An array with two entries, both of which can be +nil+ of the
  #   respective value (min / max) is not defined for this type.
  def range
    raise TypeError, "<#{@type_name}> does not support the 'range' attribute."
  end

  # Return the value this type is expected to have.
  # Only simple values are supported and they only make sense to assign expected
  # values for properties of compound objects.
  # @raise [TypeError] If this type does not support simple values (e.g. it's a compound).
  def value
    raise TypeError, "<#{@type_name}> does not support a simple value."
  end

  # Assign a pattern to check values of this type against.
  # @param [String] value A valid regular expression.
  # @raise [TypeError] If the type doesn't support pattern matching or
  #   if +value+ is not a valid regular expression.
  def pattern=( value )
    raise TypeError, "<#{@type_name}> does not support changing the 'pattern' attribute."
  end

  # Assign a set of enumeration values valid for this type.
  # @param [Array] values An array of valid values for this type.
  # @raise [TypeError] If this type doesn't support enumeration or if
  #   any of the items in +value+ doesn't match the type-class of this type.
  def enum=( values )
    raise TypeError, "<#{@type_name}> does not support changing the 'enum' attribute."
  end

  # Assign lower bound value allowed for this type.
  # @param [Fixnum] min The minimal value allowed (can be nil for no lower bound).
  # @raise [TypeError] If this type does not support ranges or if any
  #   of the parameters is not +nil+ and has a different class than the
  #   type-class of this type.
  def range_min=( min )
    raise TypeError, "<#{@type_name}> does not support changing the 'range' attribute."
  end

  # Assign the upper bound value allowed for this type.
  # @param [Fixnum] max The maximal value allowed (can be nil for no upper bound).
  # @raise [TypeError] If this type does not support ranges or if any
  #   of the parameters is not +nil+ and has a different class than the
  #   type-class of this type.
  def range_max=( max )
    raise TypeError, "<#{@type_name}> does not support changing the 'range' attribute."
  end

  # Assign the expected value for this type.
  # @param [Object] value The new expected value for this type.
  # @raise [TypeError] If this type is not compatible with assigning a simple value.
  def value=( value )
    raise TypeError, "<#{@type_name}> does not support assigning a simple value."
  end

  # Properties on compound objects

  # Set the type of items expected in arrays of this type.
  # @param [String] name The name of an existing type.
  # @raise [BasicType::TypeError] If this type does not support items or if
  #   no type matching +name+ is known.
  def item_type=( name )
    raise TypeError, "<#{@type_name}> does not support changing the 'items' attribute."
  end

  # Assign lower bound value allowed for an Array based types elements.
  # @param [Fixnum] min The minimal element count required (can be nil for no lower bound).
  # @raise [BasicType::TypeError] If this type does not support ranges or if any
  #   of the parameters is not +nil+.
  def min_items=( min )
    raise TypeError, "<#{@type_name}> does not support changing the 'min_items' attribute."
  end

  # Assign upper bound value allowed for an Array based types elements.
  # @param [Fixnum] max The maximal element count allowed (can be nil for no upper bound).
  # @raise [BasicType::TypeError] If this type does not support ranges or if any
  #   of the parameters is not +nil+.
  def max_items=( max )
    raise TypeError, "<#{@type_name}> does not support changing the 'max_items' attribute."
  end

  # Add a new property to a Hash based CompoundType.
  # @param [String] name The name for the property.
  # @param [String] type_name The name of an existing Foundation- Base- or
  #   CompoundType used for this property
  # @param [TrueClass|FalseClass] optional Mark this property as required or
  #   optional. Missing optional properties will not fail on validation.
  # @param [Object] default An optional default value if the property is omitted
  #   this value only works for types based on SimpleType.
  # @param [Array] constraints An array with additional constraint definitions
  #   that will be applied in addition to the constraints defined by +type_name+.
  # @raise [BasicType::TypeError] If the property already exists, the type_name
  #   does not already exist, this method is called on an Array based CompoundType
  #   or if a default value is supplied for a CompoundType based property.
  def add_property( name, type_name, optional=false, default=nil, constraints={} )
    raise TypeError, "<#{@type_name}> does not support the 'properties' attribute."
  end

  # Set the expected value of the property +prop+ to +value+.
  # @raise [TypeError] If the property does not exist / is a compound type / the
  #   current type is an array etc.
  def set_property( prop, value )
    if type_meta.nil?
      raise TypeError, "<#{@type_name}> does not support property values."
    else
      type_meta.set_property( prop, value )
    end
  end

  # Return a dictionary of all defined and inherited properties of this type
  # @return [Hash]
  def properties
    {}
  end

  # Return a dictionary of all defined meta_properties of this type
  # @return [Hash]
  def meta_properties
    return type_meta.properties unless type_meta.nil?
    {}
  end

  # validation

  # Verify +value+ against the constrains set by this type.
  # @param [Object] value A value matching this types type-class.
  # @return [TrueClass] if the value is valid.
  # @return [FalseClass] if any of the constrains failed to match.
  def validate( value )
    res = ValidationResult.new
    res.valid = false
    res
  end

  # Resolve any types referenced using the +ref+ property.
  # @raise [BasicType::TypeError] If any type can't be resolved.
  def resolve_references
    raise TypeError, "<#{@type_name}> - internal error, TypeClass does not implement resolve_references!"
  end
end
