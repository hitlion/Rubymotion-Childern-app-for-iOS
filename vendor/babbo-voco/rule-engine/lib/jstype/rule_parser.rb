unless RUBY_ENGINE == 'rubymotion'
  require 'ostruct'

  require 'jstype/types/simple_type'
  require 'jstype/types/derived_type'
  require 'jstype/types/compound_type'

  require 'jstype/object_validator'
  require 'jstype/validator_collection'
end

class RuleParser
  class ParserError < StandardError; end

  class << self
    # Parse a pre-parsed JSON rules definition and return the detected types and
    # the validation scope.
    # @param [Hash] data A pre-parsed JSON rules definition.
    # @return [OpenStruct] A struct with a +types+ and a +scope+ property.
    # @raise ParserError if data does not match the expectations.
    # @raise TypeError if the type definitions are invalid.
    def parse( data )
      raise ParserError, 'Expected data to be a Hash' unless data.is_a? Hash

      types = []
      # register all types in the rule set
      data.each do |key,val|
        next unless val.is_a? Hash
        next unless val.has_key? 'type'

        meta = val['property_meta']
        type = DerivedType.register_type( key, val['type'], meta )

        apply_constraints( type, val )
        types << type
      end

      # resolve any forward references, all required types must be available by now
      BasicType.rampage!

      # check if there is a validation scope
      scope = nil
      if data.has_key? 'validate'
        raise ParserError, 'Validation scope without "title".' unless data['validate'].has_key? 'title'
        raise ParserError, 'Validation scope without "items".' unless data['validate'].has_key? 'items'
        raise ParserError, 'Invalid "items" for validation.'   unless data['validate']['items'].is_a? Array

        scopes = []
        data['validate']['items'].each do |item|
          min_items = item['min_items'] || 0
          max_items = item['max_items']
          optional  = item['optional']
          scopes << ObjectValidator.new( "#{data['validate']['title']} - #{item['type']}",
                                           item['type'],
                                           min_items: min_items,
                                           max_items: max_items,
                                           optional: optional )
        end

        scope = ValidatorCollection.new( data['validate']['title'], scopes )
      end

      OpenStruct.new( types: types, scope: scope )
    end

    # Apply a set of +constraints+ to +type+.
    # This method will iterate over all of the constraints passed in, validate
    # them and if applicable assign them to the constraints and properties of
    # +type+.
    # @param [DerivedSimpleType|DerivedCompoundType] type A derived type instance.
    # @param [Hash<String,Object>] constraints A dictionary of constraints and
    #   properties which will be applied to +type+.
    # @raise [ParserError] For unexpected properties or constraints.
    def apply_constraints( type, constraints )
      constraints.each_key do |prop|
        next if %w(type ref class).include? prop

        case prop
          when 'property_meta'
            ;
          when 'properties', 'min_items', 'max_items', 'items'
            apply_compound_constraint( type, prop, constraints[prop] )

          when 'pattern'
            type.pattern = constraints[prop]
          when 'enum'
            type.enum = constraints[prop]
          when 'min'
            type.range_min = constraints[prop]
          when 'max'
            type.range_max = constraints[prop]
          else
            type.set_property( prop, constraints[prop] )
            #raise ParserError, "Unexpected property '#{prop}' on object '#{type.type_name}'"
        end
      end
    end

    def apply_compound_constraint( type, constr, value )
      unless type.is_a? CompoundType
        raise ParserError, "Attempting to set unsupported property '#{constr}' for <#{type.type_name}>."
      end

      case constr
        when 'properties'
          value.each_key do |name|
            prop_constr   = {}
            prop_type     = value[name]['type']
            prop_optional = value[name]['optional'].nil? ? true : value[name]['optional']
            prop_default  = value[name]['default']

            if prop_type.nil? and value[name].has_key? 'ref'
              prop_type = BasicType::ForwardReference.new( value[name]['ref'] )
            end

            value[name].each_key do |prop|
              # collect any additional constraints
              case prop
                when 'type', 'optional', 'default'
                  ;
                else
                  prop_constr[prop] = value[name][prop]
              end
            end

            type.add_property( name, prop_type, prop_optional, prop_default, prop_constr )
          end
        when 'items'
          # array type definition (probably..)
          unless value.has_key? 'type' or value.has_key? 'ref'
            raise ParserError, "'items' property needs a 'type' or 'ref' attribute (while reading <#{type.type_name}>)."
          end

          if value.has_key? 'type'
            type.item_type = value['type']
          elsif value.has_key? 'ref'
            type.item_type = BasicType::ForwardReference.new( value['ref'] )
          end
        when 'min_items'
          type.min_items = value
        when 'max_items'
          type.max_items = value
        else
          type.set_property( constr, value )
          #raise ParserError, "Unexpected property '#{constr}' on <#{type.type_name}>."
      end
    end
  end
end
