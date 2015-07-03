unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/wrapper'
  require 'type-monkey/splicer/core'
  require 'type-monkey/splicer/array'
  require 'type-monkey/splicer/object'
  require 'type-monkey/splicer/rules'
end

module TypeMonkey
  module Splicer
    class Error < StandardError; end

    # Splice two JSON objects into one final result
    # following the given set of +rules+ using the given +schema+.
    # @param schema [TypeMonkey::Schema] A type-monkey schema description.
    # @param rules [TypeMonkey::Rules] A type-monkey rules set (see #parse).
    # @param root [String] The root object to start the merge with.
    # @param original [Object] A parsed JSON object representing the 'original'.
    # @param modified [Ojbect] A parsed JSON object representing the 'changes'.
    # @return [Object] The result of merging +original+ and +modified+ applying
    #   +rules+ with respect the the +schema+.
    def splice( schema, rules, root, original, modified )
      root_type = TypeMonkey::Wrapper.get( schema, root )

      if root_type.is_a? TypeMonkey::Wrapper::ArrayType
        splice_master   = ArraySplicer.new( schema, root, nil, original )
        splice_modified = ArraySplicer.new( schema, root, nil, modified )

      elsif root_type.is_a? TypeMonkey::Wrapper::ObjectType
        splice_master   = ObjectSplicer.new( schema, root, nil, original )
        splice_modified = ObjectSplicer.new( schema, root, nil, modified )
      elsif root_type.is_a? TypeMonkey::Wrapper::CoreType
        splice_master   = CoreSplicer.new( schema, root, nil, original )
        splice_modified = CoreSplicer.new( schema, root, nil, modified )
      else
        raise TypeMonkey::Splicer::Error, "Internal error, this should never happen."
      end

      # create new elements etc. which use a '__copy' tag
      # by looking the path up in splice_master, creating a copy
      # and finally putting it all together as splice_original
      splice_original = Splicer.create_copy_refs( schema, root, rules,
                                                  splice_master, splice_modified )

      splice_original.splice( rules, splice_modified )
      modifiable_paths = splice_original.paths_modifiable( rules ).map { |path| rules.mapped_path( path ) }
      res = splice_original.dump
      res['__modifiable'] = modifiable_paths
      res
    end

    # Parse a set of splice-rules in parsed-JSON form
    # and create a new +Rules+ instance.
    # @param data [Object] Parsed JSON data representing the rule-set
    # @param mapping [Hash<Hash<String,String>,Hash<String,String>] A dictionary
    #   containing twe optional dictionaries 'objects' and 'paths' which will be used
    #   to map the object and path-names in the rule-set to their schema-types.
    # @return [TypeMonkey::Rules] A new +Rules+ object.
    def parse( data, mapping=nil )
      Rules.new( data, mapping || { 'objects' => {}, 'paths' => {} } )
    end

    # Dump a list of [path, type] pairs representing all of the elements
    # present in the JSON-data inside +tree+.
    # 'path' will be the splicer-path leading to a node while 'type' is the
    # associated schema-type for that node.
    # @param schema [TypeMonkey::Schema] A type-monkey schema-description.
    # @param root [String] The name of the root object inside +tree+
    # @param tree [Object] Parsed JSON data representing a document.
    # @return [Array<Array<String,String>>] An array with [path, type] pairs.
    def dump_tree( schema, root, tree )
      root_type = TypeMonkey::Wrapper.get( schema, root )

      if root_type.is_a? TypeMonkey::Wrapper::ArrayType
        splice_master   = ArraySplicer.new( schema, root, nil, tree )

      elsif root_type.is_a? TypeMonkey::Wrapper::ObjectType
        splice_master   = ObjectSplicer.new( schema, root, nil, tree )

      elsif root_type.is_a? TypeMonkey::Wrapper::CoreType
        splice_master   = CoreSplicer.new( schema, root, nil, tree )
      else
        raise TypeMonkey::Splicer::Error, "Internal error, this should never happen."
      end

      splice_master.paths.map { |path| [ path[0], path[1].type_name ] }
    end

    module_function :splice
    module_function :parse
    module_function :dump_tree

    private

    def self.create_copy_refs( schema, root, rules, master, modified )
      master_paths = master.paths.to_h
      modified.paths.each do |path, splicer|
        next unless splicer.spec.is_a? Hash

        next if splicer.spec['__copy'].nil?

        copy_from = rules.reverse_path(splicer.spec['__copy'])
        unless copy_from.nil?
          original = master_paths[copy_from]
          if original.nil?
            raise Splicer::Error, "#{path}.__copy is referencing '#{copy_from}' which is unknown."
          else
            if original.parent.nil?
              raise Splicer::Error, "#{path}.__copy is not allowed on toplevel elements."
            end

            # FIXME: this still lacks a check if +original+ accepts new elements!

            # try to insert a copy of +original+ at the end of +original.parent+
            #puts "Creating a copy of #{copy_from} for #{path}.."
            original.parent << original.class.new( schema, original.type_name,
                                                   original.parent,
                                                   original.spec,
                                                   original.index )
          end
        end
      end

      master.class.new( schema, root, nil, master.dump )
    end
  end
end

