unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/boolean'
  require 'type-monkey/wrapper'
  require 'type-monkey/validator'
end

module TypeMonkey
  module Validator
    # The base validation class also used to verify plain types like
    # +Fixnum+, +Float+, +String+ etc.
    class CoreValidator
      attr_reader :type

      # Setup a new +CoreValidator+ usind the type name +type_wrap+
      # and associate it to +schema+.
      # @param schema [TypeMonkey::Schema] A schema object used for type storage.
      # @param type_wrap [String] The name used for this type.
      def initialize( schema, type_wrap )
        @type   = type_wrap
        @schema = schema
      end

      # Validate a parsed JSON-object against the spec
      # @param object [Object] A parsed JSON object (tree).
      def validate( object )
        unless object.is_a? @type.type_class or object.is_a? Numeric # numbers are interchangable
          if object.nil?
            if @type.default_value.nil?
              raise TypeMonkey::Validator::Error,
                    "#{@type.type_name}: 'null' is not a valid value and no default was provided."
            else
              # default value is always valid..
              return true
            end
          else
            raise TypeMonkey::Validator::Error,
                  "#{@type.type_name}: type mismatch, expected #{@type.type_class} but got #{object.class}."
          end
        end

        # valid class, check the value / properties / items etc.
        validate_enum( object )
        validate_range( object )
        validate_pattern( object )
        true
      end

      # Validate a parsed JSON-object using enumerated values.
      # @see CoreType#validate
      def validate_enum( object )
        return unless [ String, Fixnum, Float ].include? @type.type_class

        if @type.spec.has_key? 'enum'
          unless @type.spec['enum'].include? object
            raise TypeMonkey::Validator::Error,
                  "#{@type.type_name}: value '#{object}' is not a member of #{@type.spec['enum']}."
          end
        elsif parent.respond_to? :validate_enum
          parent.validate_enum( object )
        end
      end

      # Validate a parsed JSON-object against a value range.
      # This is currently supported for +String+, +Fixnum+ and +Float+
      # types.
      def validate_range( object )
        return unless [ Fixnum, Float ].include? @type.type_class

        min = max = val = nil

        if @type.type_class == Fixnum
          min = @type.spec['min'].to_i if @type.spec.has_key? 'min'
          max = @type.spec['max'].to_i if @type.spec.has_key? 'max'
          val = object.to_i
        elsif @type.type_class == Float
          min = @type.spec['min'].to_f if @type.spec.has_key? 'min'
          max = @type.spec['max'].to_f if @type.spec.has_key? 'max'
          val = object.to_f
        end

        if !min.nil? and val < min
          raise TypeMonkey::Validator::Error,
                "#{@type.type_name}: value '#{val}' is below the minimal value of '#{min}'."
        end
        if !max.nil? and val > max
          raise TypeMonkey::Validator::Error,
                "#{@type.type_name}: value '#{val}' is above the maximal value of '#{max}'."
        end

        if min.nil? and max.nil? and parent.respond_to? :validate_range
          parent.validate_range( object )
        end
      end

      # Validate a parsed JSON-object against a regular expression.
      def validate_pattern( object )
        return unless @type.type_class == String

        if @type.spec.has_key? 'pattern'
          unless Regexp.new( @type.spec['pattern'] ).match( object )
            raise TypeMonkey::Validator::Error,
                  "#{@type.type_name}: value '#{object}' does not match pattern /#{@type.spec['pattern']}/."
          end
        elsif parent.respond_to? :validate_pattern
          parent.validate_pattern( object )
        end
      end

      protected

      def parent
        get_type_validator( @type.type_parent )
      end

      def get_type_validator( type_name )
        TypeMonkey::Validator::get( @schema, type_name )
      end
    end
  end
end

