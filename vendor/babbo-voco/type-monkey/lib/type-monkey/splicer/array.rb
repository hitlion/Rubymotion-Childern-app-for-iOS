unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/wrapper'
  require 'type-monkey/splicer'
end

unless Array.instance_methods.include? :to_h
  class Array
    def to_h
      res = {}
      self.each { |v| res[v.first] = v.last }
      res
    end
  end
end

module TypeMonkey
  module Splicer
    # Specialized +CoreSplicer+ with support for JSON Array types
    class ArraySplicer < CoreSplicer
      attr_reader :items

      # Create a new +ArraySplicer+ instance.
      # @param schema [TypeMonkey::Schema] A valid schema container.
      # @param type_name [String] The name of a +CoreType+ contained in +schema+.
      # @param parent [CoreSplicer] The parent node of this splicer.
      # @param definition [Object] A parsed JSON object tree
      # @param index [Fixnum] The optional starting index for array
      #   elements.
      def initialize( schema, type_name, parent, definition, index=nil )
        super
        @items = []
        item_type = "#{type_name}.item-type"

        @spec.each_with_index do |element, n|
          item  = element
          index = n
          if element.is_a? Hash
            if element.keys.sort == %w(__idx __val)
              item  = element['__val']
              index = element['__idx']
            end
          end

          if item.is_a? Hash
            @items << ObjectSplicer.new( schema, item_type, self, item, index )
          elsif item.is_a? Array
            @items << ArraySplicer.new( schema, item_type, self, item, index )
          else
            @items << CoreSplicer.new( schema, item_type, self, item, index )
          end
        end
      end

      # Return the valid properties of this splicer.
      # +ArraySplicer+ has no evaluatable properties.
      # @return [Hash] Empty.
      def properties
        {
          '$index' => @index
        }
      end

      # Append a new child to this splicer.
      # +ArraySplicer+ supports child assignment and will in turn
      # add +child+ to the end of it's item list and also set the
      # parent of +child+
      def << ( child )
        @items << child
        this = self
        child.instance_eval { @parent = this }
      end

      # Return a list of +String+, +CoreSplicer+ pairs representing
      # all paths and objects in the tree starting from this splicer.
      # @return [Array<Array<String, CoreSplicer>>] The path list.
      def paths
        res = [ [ path, self ] ]
        @items.map { |item| res += item.paths }
        res
      end

      # Merge this splicer and +modify+ according to the passed +rules+.
      # This will check if the splicer itself is modifyable and add new
      # objects as needed but will also check if the existing objects are
      # marked as modifyable and in turn call +CoreSplicer#splice+ for each
      # of them if modify contains a changed version of that object.
      # @param rules [TypeMonkey::Rules] A valid rules instance.
      # @param modify [TypeMonkey::ArraySplicer] Another +ArraySplicer+ to
      #   merge with.
      def splice( rules, modify )
        unless modify.is_a? self.class
          raise TypeMonkey::Splicer::Error, "Type mismatch - expected #{self.class} got #{modify.class}"
        end

        merge_rule = rules.find( self ) || rules.find( @parent ) || :original

        opaths = @items.map { |item| [item.path, item] }.to_h
        mpaths = modify.items.map { |item| [item.path, item] }.to_h

        # splice existing paths
        opaths.each_key do |path|
          next unless mpaths.has_key? path

          opaths[path].splice( rules, mpaths[path] )
        end

        if merge_rule == :modified
          # add additional paths
          mpaths.each_key do |path|
            next if opaths.has_key? path

            opaths[path] = mpaths[path]
          end
        end

        # regenerate @items
        @items = opaths.values
      end

      # Dump this splicer and all it's children as a ruby object tree.
      # @return [Array<Object>] An array with one object for each child.
      def dump
        @items.map{ |item| item.dump }
      end
    end
  end
end

