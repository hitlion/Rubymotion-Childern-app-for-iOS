unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/wrapper'
  require 'type-monkey/splicer'
end

module TypeMonkey
  module Splicer
    # The basic splicer implementation also used on simple types
    # like Fixnum, String, Boolean etc.
    class CoreSplicer
      attr_reader :spec
      attr_reader :parent
      attr_reader :index
      attr_reader :type_name

      # Create a new +ArraySplicer+ instance.
      # @param schema [TypeMonkey::Schema] A valid schema container.
      # @param type_name [String] The name of a +CoreType+ contained in +schema+.
      # @param parent [CoreSplicer] The parent node of this splicer.
      # @param definition [Object] A parsed JSON object tree
      # @param index [Fixnum] - unused -
      def initialize( schema, type_name, parent, definition, index=nil )
        @type_name = type_name
        @parent    = parent # FIXME: weakref?
        @spec      = definition
        @index     = index
        @schema    = schema
      end

      # Return a +String+ version of the position this splicer has in the
      # object tree.
      # This method is smart enough te reduce most redundancies and tries
      # to return the shortest representation of the path that is possible.
      # @return [String] The path to this splicer inside the tree.
      def path
        if @parent.respond_to? :type_name
          # try to remove as much duplication as possible
          fqn = "#{@type_name.gsub( /^#{@parent.type_name}/, '')}#{@index.nil? ? '' : "[#{@index}]"}"
        else
          fqn = "#{@type_name}#{@index.nil? ? '' : "[#{@index}]"}"
        end

        if @parent.respond_to? :path
          if fqn =~ /^\..*/
            # extra path shortening for propertie types
            "#{@parent.path}#{fqn}"
          else
            "#{@parent.path}:#{fqn}"
          end
        else
          ":#{fqn}"
        end
      end

      # Return the valid properties of this splicer.
      # +CoreSplicer+ is a plain data type so it only supports
      # direct value access ($value) and index access for array
      # members ($index)
      def properties
        {
          '$value' => @spec,
          '$index' => @index
        }
      end

      # Append a new child to this splicer.
      # This implementation is a catch-all since normal splicers
      # don't support adding children.
      def << ( _ )
        raise TypeMonkey::Splicer::Error, "#{path}: attempting to add a child which is not supported."
      end

      # Return a list of +String+, +CoreSplicer+ pairs representing
      # In case of a +CoreSplicer+ this list contains only the splicer
      # itself.
      #
      #In case of a +CoreSplicer+ this list contains only the splicer
      #itself.
      # @return [Array<Array<String, CoreSplicer>>] The path list.
      def paths
        [ [ path, self ] ]
      end

      # Merge this splicer and +modify+ according to the passed +rules+.
      # For a +CoreSplicer+ this will check if the value should be modifiable
      # and in that case will copy the value of +other+.
      # @param rules [TypeMonkey::Rules] A valid rules instance.
      # @param modify [TypeMonkey::CoreSplicer] Another +CoreSplicer+
      def splice( rules, other )
        merge_rule = rules.find( self ) || rules.find( @parent ) || :original
        case merge_rule
          when :original
            ;
          when :modified
            @spec = other.spec
          when :immutable
            raise TypeMonkey::Splicer::Error, "#{path}: attempting to modify immutable object."
        end
      end

      # Dump this splicer and all it's children as a ruby object tree.
      # @return [Object] The plain value type of this splicer.
      def dump
        @spec
      end
    end
  end
end

