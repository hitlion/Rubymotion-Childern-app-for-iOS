unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/boolean'
  require 'type-monkey/validator'
end

module TypeMonkey
  module Validator
    class CoreValidator; end
    class ObjectValidator < TypeMonkey::Validator::CoreValidator
      def initialize( schema, type_wrap )
        super

        if @type.type_class == Hash and @type.spec.has_key? 'properties'
          # object types (e.g. Hashes) need a sub-type for each of their properties
          @type.spec['properties'].each do |pname, pspec|
            TypeMonkey::Validator::register( @schema, "#{@type.type_name}.#{pname}" )
          end
        end
      end

      # Validate a parsed json-object against the spec
      def validate( object )
        if super
          validate_properties( object )
        end
        true
      end

      def validate_properties( object )
        return unless @type.type_class == Hash

        # Step 1: check for missing properties and verify what we've got
        injected = {}
        @type.properties.each_key do |prop_name|
          prop_type      = @type.property_type( prop_name )
          prop_validator = property_validator( prop_name )

          if object.has_key? prop_name
            begin
              prop_validator.validate( object[prop_name] )
              # try to validate if the property matches the expected default (if any)
              validate_expected_property_value( prop_name, object[prop_name] )
            rescue TypeMonkey::Validator::Error => e
              raise TypeMonkey::Validator::Error, "#{@type.type_name}: on property '#{prop_name}':\n... #{e.message}"
            end
          else
            unless prop_type.default_value.nil?
              # mark the property value for later injection
              injected[prop_name] = Marshal.load( Marshal.dump( prop_type.default_value ) )
              next
            end
            raise TypeMonkey::Validator::Error, "#{@type.type_name}: missing property '#{prop_name}'."
          end
        end
        # add the injected properties to the acutal JSON
        object.merge! injected

        # Step 2: check what object has that we don't
        object.each_key do |prop_name|
          next if @type.properties.has_key? prop_name
          # TODO: check meta type properties
          raise TypeMonkey::Validator::Error, "#{@type.type_name}: unexpected property '#{prop_name}'."
        end
      end

      def validate_expected_property_value( prop_name, value )
        if @type.spec.has_key? 'expect'
          unless @type.spec['expect'].is_a? Hash
            raise TypeMonkey::Validator::Error, "#{@type.type_name}: 'expected' values should contain a key-value hash!"
          end

          if @type.spec['expect'].has_key? prop_name
            unless @type.spec['expect'][prop_name] == value
              raise TypeMonkey::Validator::Error, "#{@type.type_name}: property '#{prop_name}'(#{value}) does not have the expected value '#{@type.spec['expect'][prop_name]}'."
            end
            true
          elsif parent.respond_to? :validate_expected_property_value
            parent.validate_expected_property_value( prop_name, value )
          else
            true
          end
        elsif parent.respond_to? :validate_expected_property_value
          # check our parent
          parent.validate_expected_property_value( prop_name, value )
        else
          # no expectation
          true
        end
      end

      def property_validator( name )
        validator = get_type_validator( "#{@type.type_name}.#{name}" )
        if validator
          # excelent, use our own property validator
          validator
        elsif parent.respond_to? :property_validator
          # query the parent validator for this property
          parent.property_validator( name )
        else
          # no, obviously undefined..
          raise "#{@type.type_name}: no validator definition available for property '#{name}'."
        end
      end
    end
  end
end

