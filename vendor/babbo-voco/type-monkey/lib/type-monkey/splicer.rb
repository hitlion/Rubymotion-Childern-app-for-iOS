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
        raise ""
      end

      # create new elements etc. which use a '__copy' tag
      # by looking the path up in splice_master, creating a copy
      # and finally putting it all together as splice_original
      splice_original = Splicer.create_copy_refs( schema, root, splice_master,
                                                  splice_modified )

      splice_original.splice( rules, splice_modified )
      splice_original.dump
    end

    def parse( data )
      Rules.new( data )
    end

    module_function :splice
    module_function :parse

    private

    def self.create_copy_refs( schema, root, master, modified )
      master_paths = master.paths.to_h
      modified.paths.each do |path, splicer|
        next unless splicer.spec.is_a? Hash

        copy_from = splicer.spec['__copy']
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

