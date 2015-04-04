unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/boolean'
  require 'type-monkey/wrapper'
end

module TypeMonkey
  module Wrapper
    class ArrayType < CoreType

      def initialize( schema, name, parent, klass, definition )
        @extra_props = %w(items)
        super

        if @type_class == Array
          if @spec.has_key? 'items'
            # arrays optionaly support defining their item types inline
            # these types can't be inherited from but they help keep the schema declaration
            # more linear
            if @spec['items']['type'].is_a? Hash

              # verify what's valid in here
              @spec['items'].each_key do |prop|
                next if %w(type min_items max_items).include? prop
                raise Wrapper::Error, "#{type_name}: unexpected key '#{prop}' in array item specification."
              end

              item_spec = @spec['items']['type']
              item_base = @spec['items']['type']['type']

              if item_spec.nil? or item_base.nil?
                raise Wrapper::Error, "#{type_name}: invalid inline item-type definition (no or empty type)."
              end
            else
              item_base = @spec['items']['type']
              item_spec = { 'type' => item_base }
            end
            Wrapper.register( @schema, "#{type_name}.item-type", item_base, item_spec )
          else
            unless parent.nil?
              # try to inherit from parents item type
              parent_items = Wrapper.get( schema, "#{parent}.item-type" )
              if parent_items.nil?
                raise Wrapper::Error, "#{type_name}: array type definition without 'items' key." unless name == 'array'
              else
                Wrapper.register( @schema, "#{type_name}.item-type", parent_items.type_name, parent_items.spec )
              end
            end
          end
        end
      end
    end
  end
end

