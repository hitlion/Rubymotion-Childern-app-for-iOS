require 'jstype/types/derived_type' unless RUBY_ENGINE == 'rubymotion'

# A wrapper around a single object based on a +BasicType+.
# +ObjectValidator+ is used to apply the constraints of a given type to the
# parsed JSON data from a document and to validate the document in that way.
class ObjectValidator
  attr_reader :title, :type, :errors

  # Setup a new +ObjectValidator+
  # @param [String] title The title for this validator
  # @param [BasicType] validated_type A type instance used to validate JSON data
  def initialize( title, validated_type, **args )
    @min_count = args.delete( :min_items ) || 0
    @max_count = args.delete( :max_items )
    @optional  = args.delete( :optional ) ? true : false

    @title = title
    @type = DerivedType.type_with_name( validated_type )
    @errors =[]
    @valid = true
  end

  # Apply all known constraints to +value+ and check if it passes.
  # @param [Hash|Array] value The parsed JSON document data
  def validate( value )
    @valid = true
    @errors = []

    if value.is_a? Array
      # bounds check if value contains more than one item
      if value.count < @min_count or ( @max_count and value.count > @max_count )
        @valid = false
        @errors << "Number of items exceeds the valid range of { #{@min_count}, #{@max_count || 'inf'} }."
      end

      value.each do |val|
        res = @type.validate( val )
        if res.valid == false and @optional == false
          @valid = false
          @errors += res.errors
        end

        if @type.is_a? SimpleType and @type.value and @type.value != val
          @valid = false
          @errors << "Value '#{val}' does not match the expected value '#{@type.value}'."
        end
      end
    else
      res = @type.validate( value )
      if res.valid == false and @optional == false
        @valid = false
        @errors += res.errors
      end

      if @type.is_a? SimpleType and @type.value and @type.value != value
        @valid = false
        @errors << "Value '#{value}' does not match the expected value '#{@type.value}'."
      end
    end

    @valid
  end

  # Shortcut to check if the last validation was a success.
  def valid?
    @valid
  end
end
