require 'jstype/types/basic_type' unless RUBY_ENGINE == 'rubymotion'

# Hack to have one common "class" to pack true and false into..
module Boolean
end

class TrueClass
  include Boolean
end

class FalseClass
  include Boolean
end

# +SimpleType+ encapsulates the fundamental JSON data types that ruby
# can map to native objects. These include:
# - string  => String
# - integer => Fixnum
# - float   => Float
# Depending on the underlying type a +SimpleType+ supports validation
# against different criteria including pattern match, enum match, range check
# as well as match-on-keys (e.g. compare properties).
class SimpleType < BasicType
  class << self
    # Register a new foundation type.
    # @param [String] type_name The name for this type.
    # @param [Class] type_class The native ruby class to map this type to.
    # @param [TrueClass|FalseClass] support_pattern Whether this type supports
    #   the 'pattern' attribute.
    # @param [TrueClass|FalseClass] support_enum Whether this type supports the
    #   'enum' attribute.
    # @param [TrueClass|FalseClass] support_range Whether this type supports the
    #   'range' attribute.
    # @return [SimpleType] The new type instance
    # @raise [BasicType::TypeError] If the +type_name+ is already in use.
    def register_type( type_name, type_class, support_pattern, support_enum, support_range )
      if BasicType.type_registry.has_key? type_name
        raise BasicType::TypeError, "Attempting to redefine '#{type_name}'."
      end

      type = SimpleType.new( type_name )
      type.instance_eval do
        @type_class = type_class
        @supports[:pattern] = support_pattern
        @supports[:enum]    = support_enum
        @supports[:range]   = support_range
      end

      BasicType.type_registry[type_name] = type
      type
    end

    # prevent direct calls to #new
    protected :new
  end

  # Create a new type with a given name (not intended for public usage).
  # @param [String] type_name The name used to identify this type.
  # @private
  def initialize( type_name, metaclass=nil )
    super( type_name, nil, metaclass )

    @match_pattern  = nil
    @match_enum     = []
    @match_range    = [nil, nil]
    @supports       = { :pattern => false, :enum => false, :range => false }
    @expected_value = nil
  end

  # @see BasicType.range
  def pattern
    @match_pattern
  end

  # @see BasicType.enum
  def enum
    @match_enum
  end

  # @see BasicType.range
  def range
    @match_range
  end

  # @see BasicType.value
  def value
    @expected_value
  end

  # @see BasicType.pattern=
  def pattern=( value )
    unless @supports[:pattern]
      raise BasicType::TypeError, "<#{type_name}> does not support 'pattern' attribute."
    end

    if value.nil?
      @match_pattern = nil
    else
      begin
        exp = Regexp.new( value )
        @match_pattern = exp
      rescue RegexpError
        raise BasicType::TypeError, "'#{value}' is not a valid regular expression."
      end
    end
  end

  # @see BasicType.enum=
  def enum=( values )
    unless @supports[:enum]
      raise BasicType::TypeError, "<#{type_name}> does not support 'enum' attribute."
    end

    if values.nil? or values.empty?
      @match_enum = []
    else
      values.each do |val|
        raise BasicType::TypeError, "enumeration value '#{val}' is not of type #{type_class}." unless val.is_a? type_class
      end

      @match_enum = values
    end
  end

  # @see BasicType.range_min=
  def range_min=( min )
    unless @supports[:range]
      raise BasicType::TypeError, "<#{type_name}> does not support 'range' attribute."
    end

    unless min.nil? or min.is_a? type_class
      raise BasicType::TypeError, "range_min( #{min} ) is not of type #{type_class}."
    end

    if !min.nil? and !@match_range[1].nil? and min > @match_range[1]
      raise BasicType::TypeError, "range( #{min} ) - min must be smaller than max."
    end

    @match_range[0] = min
  end

  # @see BasicType.range_max=
  def range_max=( max )
    unless @supports[:range]
      raise BasicType::TypeError, "<#{type_name}> does not support 'range' attribute."
    end

    unless max.nil? or max.is_a? type_class
      raise BasicType::TypeError, "range_min( #{max} ) is not of type #{type_class}."
    end

    if !max.nil? and !@match_range[0].nil? and max < @match_range[0]
      raise BasicType::TypeError, "range( #{max} ) - max must be larger than min."
    end

    @match_range[1] = max
  end

  # @see BasicType.value=
  def value=( value )
    if validate( value )
      @expected_value = value
      true
    else
      false
    end
  end

  # @see BasicType.validate
  def validate( value )
    res = ValidationResult.new
    unless value.is_a? type_class
      res.errors << "#{type_name}: Type mismatch <#{type_class}> vs #{value.class.to_s}."
      res.valid = false
      return res
    end

    if @supports[:pattern] and !@match_pattern.nil?
      unless @match_pattern.match( value )
        res.valid = false
        res.errors << "#{type_name}: '#{value}' doesn\\'t match pattern /#{@match_pattern.to_s}/."
      end
    end

    if @supports[:enum] and !@match_enum.empty?
      unless @match_enum.include? value
        res.valid = false
        res.errors << "#{type_name}: '#{value}' is not a valid value, expected [#{@match_enum.to_s}]."
      end
    end

    if @supports[:range]
      if ( !@match_range[0].nil? and value < @match_range[0] ) or \
         ( !@match_range[1].nil? and value > @match_range[1] )
        res.valid = false
        res.errors << "#{type_name}: '#{value}' is out of range { #{@match_range[0] || 0}, #{@match_range[1] || 'inf'} }."
      end
    end

    res
  end

  # @see BasicType.resolve_references
  # A +SimpleType+ has no nested or complex properties or constraints.
  # So basically it can never have any unresolved references.
  def resolve_references
    true
  end
end

SimpleType.register_type( 'string' , String , true , true , false )
SimpleType.register_type( 'integer', Fixnum , false, true , true  )
SimpleType.register_type( 'float'  , Float  , false, true , true  )
SimpleType.register_type( 'boolean', Boolean, false, false, false )
