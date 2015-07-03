unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/wrapper'
  require 'type-monkey/splicer'
end

module TypeMonkey
  module Splicer
    # Specialized +CoreSplicer+ with support for JSON Object types.
    class ObjectSplicer < CoreSplicer
      attr_reader :props

      # Create a new +ArraySplicer+ instance.
      # @param schema [TypeMonkey::Schema] A valid schema container.
      # @param type_name [String] The name of a +CoreType+ contained in +schema+.
      # @param parent [CoreSplicer] The parent node of this splicer.
      # @param definition [Object] A parsed JSON object tree
      # @param index [Fixnum] - unused -
      #   elements.
      def initialize( schema, type_name, parent, definition, index=nil )
        super
        @props = {}
        spec_type = Wrapper.get( schema, @type_name )
        spec_type.properties.each_pair do |name, prop|
          #next if @spec[name].nil?

          ptype = spec_type.property_type( name )
          value = @spec[name] || ptype.default_value

          if ptype.type_class == Hash
            @props[name] = ObjectSplicer.new( schema, ptype.type_name, self, value || {} )
          elsif ptype.type_class == Array
            @props[name] = ArraySplicer.new( schema, ptype.type_name, self, value || [] )
          else
            @props[name] = CoreSplicer.new( schema, ptype.type_name, self, value )
          end
        end
      end

      # Return the valid properties of this splicer.
      # +ObjectSplicer+ will return a Hash with key-value pairs
      #   for all the +CoreSplicer+ based properties it contains.
      # @return [Hash<String,Object>] The property list
      def properties
        # select all core-type properties
        res = {}
        @props.each_pair do |prop, val|
          if val.is_a? CoreSplicer
            res[prop] = val.dump
          end
        end
        res['$index'] = @index
        res
      end

      # Return a list of +String+, +CoreSplicer+ pairs representing
      # all paths and objects in the tree starting from this splicer.
      # @return [Array<Array<String, CoreSplicer>>] The path list.
      def paths
        res = [ [ path, self ] ]
        @props.each_pair do |prop, val|
          res += val.paths
        end
        res
      end

      def paths_modifiable( rules )
        merge_rule = rules.find( self ) || rules.find( @parent ) || :original
        if merge_rule == :modified
          res = [ path ]
        else
          res = []
        end
        @props.each_pair do |_, val|
          res += val.paths_modifiable( rules )
        end
        res
      end

      # Merge this splicer and +modify+ according to the passed +rules+.
      # This will check if the splicer itself is modifyable and add new
      # properties as needed but will also check if the existing ones are
      # marked as modifyable and in turn call +CoreSplicer#splice+ for each
      # of them if modify contains a changed version of that property.
      # @param rules [TypeMonkey::Rules] A valid rules instance.
      # @param modify [TypeMonkey::ObjectSplicer] Another +ObjectSplicer+ to
      #   merge with.
      def splice( rules, other )
        merge_rule = rules.find( self ) || rules.find( @parent ) || :original

        # splice existing
        @props.each_key do |prop|
          next unless other.props.has_key? prop # not present
          next if other.props[prop].spec.nil?   # present but undefined

          @props[prop].splice( rules, other.props[prop] )
        end

        if merge_rule == :modified
          # add new
          other.props.each_key do |prop|
            next if @props.has_key? prop         # not present
            next if other.props[prop].spec.nil?  # present but undefined

            @props[prop] = other.props[prop]
          end
        end
      end
      #
      # Dump this splicer and all it's children as a ruby object tree.
      # @return [Hash<String,Object>] A hash with one object for each property.
      def dump
        res = {}
        @props.each_pair do |prop, val|
          res[prop] = val.dump
        end
        res
      end
    end
  end
end

