unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/boolean'
  require 'type-monkey/wrapper/core'
  require 'type-monkey/wrapper/object'
  require 'type-monkey/wrapper/array'
end

module TypeMonkey
  module Wrapper
    class Error < StandardError; end

    def register( schema, name, parent, definition )
      schema.types ||= Wrapper::prepare_base_types( schema )

      if schema.types.has_key? name
        raise Wrapper::Error, "Attempting to redefine type '#{name}'."
      end

      if !schema.types.has_key? parent
        raise Wrapper::Error, "Undefined parent type '#{parent}' for '#{name}'."
      end

      if Wrapper.get( schema, parent ).type_class == Hash
        type = ObjectType.new( schema, name, parent, nil, definition )
      elsif Wrapper.get( schema, parent ).type_class == Array
        type = ArrayType.new( schema, name, parent, nil, definition )
      else
        type = CoreType.new( schema, name, parent, nil, definition )
      end

      schema.types[name] = type
      type
    end

    def get( schema, name )
      schema.types ||= Wrapper::prepare_base_types( schema )
      schema.types[name]
    end

    module_function :register
    module_function :get

    private

    def self.prepare_base_types( schema )
      # Hook in the basic type definitions if they happen to not exist.
      {
        'string'  => CoreType.new( schema, 'string',  nil, String,  {} ),
        'integer' => CoreType.new( schema, 'integer', nil, Fixnum,  {} ),
        'float'   => CoreType.new( schema, 'float',   nil, Float,   {} ),
        'boolean' => CoreType.new( schema, 'boolean', nil, Boolean, {} ),
        'object'  => ObjectType.new( schema, 'object',  nil, Hash,  {} ),
        'array'   => ArrayType.new( schema,  'array',  nil, Array, {} )
      }
    end
  end
end

