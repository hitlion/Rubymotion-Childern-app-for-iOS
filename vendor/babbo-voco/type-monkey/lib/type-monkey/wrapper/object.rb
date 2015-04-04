unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/boolean'
  require 'type-monkey/wrapper'
end

module TypeMonkey
  module Wrapper
    class ObjectType < CoreType
      def initialize( schema, name, parent, klass, definition )
        @extra_props = %w(properties expect)
        super

        if @type_class == Hash and @spec.has_key? 'properties'
          # object types (e.g. Hashes) need a sub-type for each of their properties
          @spec['properties'].each do |pname, pspec|
            Wrapper.register( @schema, "#{type_name}.#{pname}", pspec['type'], pspec )
          end
        end
      end

      def properties
        props = @spec['properties'] || {}
        if parent.nil?
          props
        else
          parent.properties.merge( props )
        end
      end

      def property_type( name )
        type = get_type( "#{type_name}.#{name}" )
        if type
          # excelent, use our own property type
          type
        elsif parent.respond_to? :property_type
          # query the parent type for this property
          parent.property_type( name )
        else
          # no, obviously undefined..
          raise Wrapper::Error, "#{type_name}: no type definition available for property '#{name}'."
        end
      end
    end
  end
end

