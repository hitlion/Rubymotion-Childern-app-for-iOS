unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/boolean'
  require 'type-monkey/wrapper'
  require 'type-monkey/validator/core'
  require 'type-monkey/validator/array'
  require 'type-monkey/validator/object'
end

module TypeMonkey
  module Validator
    class CoreValidator; end
    class Error < StandardError; end

    def get( schema, type_name )
      schema.validators ||= TypeMonkey::Validator::prepare_base_validators( schema )
      schema.validators[type_name]
    end

    def register( schema, type_name )
      schema.validators ||= TypeMonkey::Validator::prepare_base_validators( schema )

      unless schema.validators.has_key? type_name
        type = TypeMonkey::Wrapper.get( schema, type_name )

        if type.type_class == Array
          validator = TypeMonkey::Validator::ArrayValidator.new( schema, type )
        elsif type.type_class == Hash
          validator = TypeMonkey::Validator::ObjectValidator.new( schema, type )
        else
          validator = TypeMonkey::Validator::CoreValidator.new( schema, type )
        end
        schema.validators[type_name] = validator
      end
    end

    def validate( schema, object, toplevel )
      # prepare the schema
      begin
        schema.types.each_key do |type_name|
          register( schema, type_name ) unless schema.validators.has_key? type_name
        end
      rescue TypeMonkey::Validator::Error => e
        raise TypeMonkey::Validator::Error, "Error while creating the validation scope:\n... #{e.message}"
      end

      if schema.validators.has_key? toplevel
        schema.validators[toplevel].validate( object )
      else
        raise TypeMonkey::Validator::Error, "Error '#{toplevel}' does not name a known type specification"
      end
      true
    end

    module_function :get
    module_function :register
    module_function :validate

    private

    def self.prepare_base_validators( schema )
      # Hook in the basic type definitions if they happen to not exist.
      {
        'string'  => TypeMonkey::Validator::CoreValidator.new( schema, TypeMonkey::Wrapper.get( schema, 'string'  ) ),
        'integer' => TypeMonkey::Validator::CoreValidator.new( schema, TypeMonkey::Wrapper.get( schema, 'integer' ) ),
        'float'   => TypeMonkey::Validator::CoreValidator.new( schema, TypeMonkey::Wrapper.get( schema, 'float'   ) ),
        'boolean' => TypeMonkey::Validator::CoreValidator.new( schema, TypeMonkey::Wrapper.get( schema, 'boolean' ) ),
        'object'  => TypeMonkey::Validator::ObjectValidator.new( schema, TypeMonkey::Wrapper.get( schema, 'object' ) ),
        'array'   => TypeMonkey::Validator::ArrayValidator.new( schema, TypeMonkey::Wrapper.get( schema, 'array'  ) )
      }
    end
  end
end

