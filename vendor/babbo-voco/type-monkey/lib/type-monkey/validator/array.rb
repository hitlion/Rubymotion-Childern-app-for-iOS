unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/boolean'
  require 'type-monkey/validator'
end

module TypeMonkey
  module Validator
    class CoreValidator; end
    class ArrayValidator < TypeMonkey::Validator::CoreValidator

      def initialize( schema, type_wrap )
        super
        if @type.type_class == Array and @type.spec.has_key? 'items'
          # arrays optionaly support defining their item types inline
          # so make sure that each required type has a validator object
          if @type.spec['items']['type'].is_a? String
            # make sure the validator for this type exists
            if get_type_validator( @type.spec['items']['type'] ).nil?
              TypeMonkey::Validator::register( @schema, @type.spec['items']['type'] )
            end
          end

          if get_type_validator( "#{@type.type_name}.item-type" ).nil?
            # make sure the validator for the derived item-type exists
            TypeMonkey::Validator::register( @schema, "#{@type.type_name}.item-type" )
          end
        end
      end

      # Validate a parsed json-object against the spec
      def validate( object )
        if super
          validate_items( object )
        end
        true
      end

      def validate_items( object )
        return unless @type.type_class == Array

        # Step 1: check min/max violations
        if @type.spec.has_key? 'items'
          item_spec = @type.spec['items']
          if item_spec.has_key? 'min_items' and object.size < item_spec['min_items'].to_i
            raise TypeMonkey::Validator::Error,
                  "#{@type.type_name}: wrong number of items(#{object.size}) - expected at least #{item_spec['min_items']}."
          end

          if item_spec.has_key? 'max_items' and object.size > item_spec['max_items'].to_i
            raise TypeMonkey::Validator::Error,
                  "#{@type.type_name}: wrong number of items(#{object.size}) - expected at most #{item_spec['max_items']}."
          end

          # Step 2: validate the items
          if item_spec.has_key? 'type'
=begin
            if item_spec['type'].is_a? String
              # reference to an existing type
              item_validator = get_type_validator( item_spec['type'] )
            elsif item_spec['type'].is_a? Hash
              # inline definition
              item_validator = get_type_validator( "#{@type.type_name}_item-type" )
            end
=end
            item_validator = get_type_validator( "#{@type.type_name}.item-type" )
            # the next exception clearly should *never* happen..
            raise TypeMonkey::Validator::Error,
                  "#{@type.type_name}: invalid / missing item type!" if item_validator.nil?

            object.each_with_index do |item, n|
              begin
                item_validator.validate( item )
              rescue TypeMonkey::Validator::Error => e
                # add the index to the error to help locating it in the JSON
                raise TypeMonkey::Validator::Error,
                      "#{@type.type_name}: on item[#{n}]:\n... #{e.message}"
              end
            end
          end

        elsif parent.respond_to? :validate_items
          begin
            parent.validate_items( object )
          rescue Validator::Error => e
            raise TypeMonkey::Validator::Error, "#{@type.type_name}:\n... #{e.message}"
          end
        else
          raise TypeMonkey::Validator::Error,
                "#{@type.type_name}: incomplete type specification (no 'items' property defined)."
        end
      end
    end
  end
end

