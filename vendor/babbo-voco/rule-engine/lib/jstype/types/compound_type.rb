unless RUBY_ENGINE == 'rubymotion'
  require 'jstype/types/basic_type'
  require 'jstype/types/derived_type'

  require 'jstype/rule_parser'
end

class CompoundType < BasicType
  class << self
    # Register a new compound type (array / object).
    # @param [String] type_name The name for this type.
    # @param [Class] type_class The native ruby class to map this type to.
    # @return [CompoundType] The new type instance
    # @raise [BasicType::TypeError] If the +type_name+ is already in use.
    def register_type( type_name, type_class )
      if BasicType.type_registry.has_key? type_name
        raise BasicType::TypeError, "Attempting to redefine '#{type_name}'."
      end

      unless type_class == Array or type_class == Hash
        raise BasicType::TypeError, 'Compound types only support Array and Hash as type_class.'
      end

      type = CompoundType.new( type_name, type_class )
      BasicType.type_registry[type_name] = type
      type
    end

    # @see BasicType.type_with_name
    def type_with_name( name )
      BasicType.type_registry[name]
    end

    # prevent direct calls to #new
    protected :new
  end

  # Create a new type with a given name and type_class (not intended for public usage).
  # @param [String] type_name The name used to identify this type.
  # @param [Class] type_class The native ruby class for this type (Array or Hash).
  # @private
  def initialize( type_name, type_class, metaclass=nil )
    super( type_name, type_class, metaclass )

    @prop_spec  = {}
    @item_spec  = { :min => nil, :max => nil }

    unless type_class == Array || type_class == Hash
      raise BasicType::TypeError, 'Compound types only support Array and Hash as type_class'
    end
  end

  # Return an instance of the type of items expected in arrays of this type.
  def item_type
    if type_class == Hash
      raise BasicType::TypeError, "#{type_name} is a Hash compound type and doesn't support 'items' attribute."
    end
    if @item_spec[:type].is_a? BasicType::ForwardReference
      @item_spec[:type].resolve
    else
      BasicType.type_with_name( @item_spec[:type] )
    end
  end

  # Return the min/max range of values valid for this type.
  # @return [Array] An array with two entries, both of which can be +nil+ of the
  #   respective value (min / max) is not defined for this type.
  def range
    if type_class == Hash
      raise BasicType::TypeError, "#{type_name} is a Hash compound type and doesn't support 'range' attribute."
    end

    [ @item_spec[:min], @item_spec[:max] ]
  end

  # Set the type of items expected in arrays of this type.
  # @param [String|BasicType::ForwardReference] name The name of an existing type.
  #   or a forward reference to a to-be-defined type.
  # @raise [BasicType::TypeError] If this type does not support items or if
  #   no type matching +name+ is known.
  def item_type=( name )
    if type_class == Hash
      raise BasicType::TypeError, "#{@type_name} is a Hash compound type and doesn't support 'items' attribute."
    end

    if self.class != DerivedCompoundType
      raise BasicType::TypeError, "#{@type_name} is polluting the base class.."
    end

    unless name.is_a? BasicType::ForwardReference
      # check if this type actually exists
      if CompoundType.type_with_name( name ).nil?
        raise BasicType::TypeError, "Unknown item type '#{name}' for <#{@type_name}>"
      end
    end

    @item_spec[:type] = name
  end

  # Assign lower bound value allowed for an Array based types elements.
  # @param [Fixnum] min The minimal element count required (can be nil for no lower bound).
  # @raise [BasicType::TypeError] If this type does not support ranges or if any
  #   of the parameters is not +nil+.
  def min_items=( min )
    unless type_class == Array
      raise BasicType::TypeError, "<#{@type_name}> does not support the 'min_items' attribute."
    end

    unless min.nil? or min.is_a? Fixnum
      raise BasicType::TypeError, "min_items( #{min} ) is not a number."
    end

    if !min.nil? and !@item_spec[:max].nil? and min > @item_spec[:max]
      raise BasicType::TypeError, "min_items( #{min} ) - min must be smaller than max."
    end

    @item_spec[:min] = min
  end

  # Assign upper bound value allowed for an Array based types elements.
  # @param [Fixnum] max The maximal element count allowed (can be nil for no upper bound).
  # @raise [BasicType::TypeError] If this type does not support ranges or if any
  #   of the parameters is not +nil+.
  def max_items=( max )
    unless type_class == Array
      raise BasicType::TypeError, "<#{@type_name}> does not support the 'max_items' attribute."
    end

    unless max.nil? or max.is_a? Fixnum
      raise BasicType::TypeError, "max_items( #{max} ) is not a number."
    end

    if !max.nil? and !@item_spec[:min].nil? and max < @item_spec[:min]
      raise BasicType::TypeError, "max_items( #{max} ) - max must be greater than min."
    end

    @item_spec[:max] = max
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
    unless type_class == Hash
      raise BasicType::TypeError, "<#{@type_name}> does not support the 'properties' attribute."
    end

    if @prop_spec.has_key? name
      raise BasicType::TypeError, "Attempting to redefine property '#{name}' on <#{@type_name}>."
    end

    if type_name.is_a? BasicType::ForwardReference
      # in case of forward references the property won't be derived until the
      # resolving stage.
      prop_type = type_name

      @prop_spec[name] = {
          :type     => prop_type,
          :optional => optional,
          :default  => default,
          :constr   => constraints
      }
    else
      type_instance = DerivedType.type_with_name( type_name )
      if type_instance.nil?
        raise BasicType::TypeError, "Unknown type '#{type_name}' for property '#{name}' on <#{@type_name}>."
      end

      if type_instance.is_a? CompoundType and !default.nil?
        raise BasicType::TypeError, "Attempting to set a default value for compound-type property '#{name}' on <#{@type_name}>."
      end

      metaclass = type_instance.type_meta || type_meta
      metaclass = metaclass.type_name unless metaclass.nil?

      prop_type = DerivedType.register_type( "#{@type_name}::#{name}", type_name, metaclass )
      RuleParser.apply_constraints( prop_type, constraints )

      @prop_spec[name] = {
          :type     => prop_type.type_name,
          :optional => optional,
          :default  => default || nil
      }
    end
  end

  # @see BasicType.set_property
  def set_property( prop, value )
    if type_class == Array
      raise BasicType::TypeError, "Attempting to set an expected value for array-type <#{@type_name}>."
    end

    if @prop_spec.has_key? prop
      if DerivedType.type_with_name( @prop_spec[prop][:type] ).validate( value )
        DerivedType.type_with_name( @prop_spec[prop][:type] ).value = value
      else
        raise BasicType::TypeError, "Invalid expected value for property '#{prop}' on <#{@type_name}>"
      end
    else
      raise BasicType::TypeError, "Invalid property '#{prop}' on <#{@type_name}>"
    end
  end

  # @see BasicType.properties
  def properties
    @prop_spec.merge( super )
  end

  # @see BasicType.validate
  def validate( value )
    res = ValidationResult.new
    unless value.is_a? type_class
      res.valid = false
      res.errors << "#{@type_name}: Type mismatch <#{type_class}> vs #{value.class.to_s}"
      return res
    end

    if type_class == Array
      if ( !@item_spec[:min].nil? and value.count < @item_spec[:min] ) or \
         ( !@item_spec[:max].nil? and value.count > @item_spec[:max] )
        res.valid = false
        res.errors << "#{@type_name}: item count is out of range { #{@item_spec[:min] || 0}, #{@item_spec[:max] || 'inf'} }."
        return res
      end

      value.each do |item|
        tmp = item_type.validate( item )
        res.errors += tmp.errors
        return res unless res.valid &= tmp.valid
      end
    else # Hash
      # validate each property
      value.each_key do |prop|
        # check for undefined property
        unless properties.has_key? prop
          res.valid = false
          res.errors << "#{@type_name}: unsupported property '#{prop}' (have: #{properties.keys})."
          return res
        end

        # apply constraints
        type_inst = DerivedType.type_with_name( properties[prop][:type] )
        tmp = type_inst.validate( value[prop] )
        res.errors += tmp.errors
        return res unless res.valid &= tmp.valid

        # check default value
        unless type_inst.is_a? CompoundType
          if type_inst.value and \
             type_inst.value != value[prop]
            res.errors << "#{@type_name}: property '#{prop}' does not have the required value '#{type_inst.value}' (value='#{value[prop]}')."
            res.valid = false
          end
        end
      end

      # check for missing non-optional properties
      properties.each_key do |prop|
        unless value.has_key? prop or properties[prop][:optional]
          res.errors << "#{@type_name}: mandatory property '#{prop}' is missing."
        end
      end
    end
    res
  end

  # @see BasicType.resolve_references
  def resolve_references
    if type_class == Hash
      # Check all properties on Hash based compound types
      type_references = []
      @prop_spec.each_key do |prop|
        if @prop_spec[prop][:type].is_a? BasicType::ForwardReference
          if ( type = @prop_spec[prop][:type].resolve ).nil?
            raise BasicType::TypeError, "Unresolved type reference to '<#{@prop_spec[prop][:type].referenced_type}>' for '#{prop}' property on <#{@type_name}>."
          else
            # remove the forward reference remembering the parameters
            type_references << [ prop, type, @prop_spec.delete( prop ) ]
          end
        end
      end
      # replace the forward references with actual derived property types
      type_references.each do |ref|
        add_property( ref[0], ref[1].type_name, ref[2][:optional], ref[2][:default], ref[2][:constr] )
        # and try to validate that
        DerivedType.type_with_name( @prop_spec[ref[0]][:type] ).resolve_references
      end
    else
      # Check and resolve the +item_type+ on Array based compounds
      if @item_spec[:type].is_a? BasicType::ForwardReference
        if ( type = @item_spec[:type].resolve ).nil?
          raise BasicType::TypeError, "Unresolved type reference to '<#{@item_spec[:type].referenced_type}>' for 'items' property on <#{@type_name}>."
        else
          @item_spec[:type] = type.type_name
          type.resolve_references
        end
      end
    end
  end

  protected
  def prop_spec
    @prop_spec
  end

  def item_spec
    @item_spec
  end
end

CompoundType.register_type( 'object', Hash )
CompoundType.register_type( 'array', Array )
