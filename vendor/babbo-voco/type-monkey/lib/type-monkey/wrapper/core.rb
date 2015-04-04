unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/boolean'
  require 'type-monkey/wrapper'
end

module TypeMonkey
  module Wrapper
    class CoreType
      attr_reader :type_name, :type_parent, :type_class, :spec

      def initialize( schema, name, parent, klass, definition )
        @type_name   = name
        @type_parent = parent
        @type_class  = klass || schema.types[parent].type_class
        @schema      = schema
        @spec        = definition
        @extra_props ||= []

        check_spec( @extra_props )
      end

      def default_value
        if @spec.has_key? 'default'
          unless @spec['default'].is_a? type_class
            # FIXME: maybe be a little more concrete?
            raise Wrapper::Error, "#{type_name}: default value is of the wrong type."
          end
          @spec['default']
        elsif parent.respond_to? :default_value
          begin
            parent.default_value
          rescue Wrapper::Error => e
            # add the default value context and re-raise
            raise Wrapper::Error, "#{type_name}: checking for a default value..\n... #{e.message}"
          end
        else
          nil
        end
      end

      def expected_value
        return nil unless type_class == Hash
      end

      protected

      def parent
        get_type( @type_parent )
      end

      def get_type( type_name )
        Wrapper.get( @schema, type_name )
      end

      def check_spec( extra_props )
        @spec.each_key do |prop|
          next if %w(type enum pattern min max default splice).include? prop
          next if extra_props.include? prop

          raise Wrapper::Error, "#{type_name}: unexpected key '#{prop}' in type specification."
        end
      end
    end
  end
end

