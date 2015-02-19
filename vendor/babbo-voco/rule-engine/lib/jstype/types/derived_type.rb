unless RUBY_ENGINE == 'rubymotion'
  require 'jstype/types/simple_type'
  require 'jstype/types/compound_type'
end

# +DerivedType+ covers all the types which are direct descendants of a registered
# +SimpleType+ e.g. something "refining" a string, integer, float etc. or a
# registered +CompoundType+ e.g. something "refining" an array or object.
class DerivedType
  class << self
    # Register a new type derived from an existing +SimpleType+ or +CompoundType+.
    # @param [String] type_name A unique name for the new type.
    # @param [String] super_type_name The name of the foundation type used
    #   to derive this type.
    # @return [DerivedType] The new +BaseType+ instance
    def register_type( type_name, super_type_name, metaclass=nil )

      if BasicType.type_registry.has_key? type_name
         raise TypeError, "Attempting to redefine '#{type_name}'."
      end

      if ( base = BasicType.type_with_name( super_type_name ) ).nil?
        raise TypeError, "Unknown base type '#{super_type_name}'"
      end

      if metaclass.nil?
        if base.type_meta.nil?
          meta_type = nil
        else
          meta_type = DerivedType.register_type( "#{type_name}::_meta", base.type_meta.type_name, nil ).type_name
        end
      else
        meta_type = DerivedType.register_type( "#{type_name}::_meta", metaclass ).type_name
      end

      if base.is_a? SimpleType
        type = DerivedSimpleType.new( type_name, base, meta_type )
      else
        type = DerivedCompoundType.new( type_name, base, meta_type )
      end

      BasicType.type_registry[type_name] = type
      type
    end

    # @see BaseType.type_with_name
    def type_with_name( name )
      BasicType.type_with_name( name )
    end

    # prevent ever creating an instance of this..
    private :new
  end
end

# A type class derived from one of the defined +SimpleType+ instances or from
# another +DerivedSimpleType+.
class DerivedSimpleType < SimpleType
  class << self
    def new( *args ); super; end
  end

  def initialize( type_name, super_type, metaclass=nil )
    super( type_name, metaclass )

    @parent        = super_type
    @match_pattern = super_type.pattern
    @match_enum    = super_type.enum
    @match_range   = super_type.range

    @supports = super_type.instance_eval { @supports }

    raise TypeError, 'super_type must not be nil' if super_type.nil?
  end

  # @see BasicType.type_class
  def type_class
    @parent.type_class
  end

  # @see BasicType.type_meta
  def type_meta
    @type_meta
  end

  # Try to set a property on this type.
  # This will only work if there is a usable property_meta defined.
  # @param [String] prop The name of the property
  # @param [Object] value The value to set the property to
  # @raise [BasicType::TypeError] If setting this property is not supported.
  def set_property( prop, value )
    raise "#{type_name}: attempting to set a property '#{prop}' on a derived simple type.." if type_meta.nil?
    type_meta.set_property( prop, value )
  end

  # @see BasicType.validate
  def validate( value )
    res = @parent.validate( value )
    if res.valid
      super
    else
      res.errors << "#{type_name}: parent failed to validate"
      res
    end
  end
end

# A type class derived from one of the defined +CompoundType+ instances or from
# another +DerivedCompoundType+.
class DerivedCompoundType < CompoundType
  class << self
    def new( *args ); super; end
  end

  # @see CompoundType.initialize
  def initialize( type_name, super_type, metaclass=nil )
    super( type_name, super_type.type_class, metaclass )
    @parent = super_type
    raise TypeError, 'super_type must not be nil' if super_type.nil?

    # inherit parent's array properties (if any, it makes things simpler..)
    @item_spec = Marshal.load( Marshal.dump( super_type.item_spec ) )
    @prop_spec = derive_properties( super_type )
  end

  # @see BasicType.type_class
  def type_class
    @parent.type_class
  end

  # @see BasicType.type_meta
  def type_meta
    @type_meta
  end

#  # Set the expected value of the property +prop+ to +value+.
#  # @raise [TypeError] If the property does not exist / is a compound type / the
#  #   current type is an array etc.
  def set_property( prop, value )
    if type_class == Array
      if type_meta.nil?
        raise BasicType::TypeError, "Attempting to set an expected value for array-type <#{@type_name}>."
      else
        type_meta.set_property(prop, value)
      end
    end
    if @prop_spec.has_key? prop
      type_inst = DerivedType.type_with_name( @prop_spec[prop][:type] )
      if type_inst.validate( value )
        type_inst.value = value
      end
    elsif ! type_meta.nil?
      begin
        type_meta.set_property( prop, value )
      rescue
        super
      end
    else
      super
    end
  end

  private

  def derive_properties( super_type )
    @prop_spec = {}
    super_type.properties.each do |name, prop|
      add_property( name, prop[:type], prop[:optional], prop[:default] )
    end
    @prop_spec
  end
end

