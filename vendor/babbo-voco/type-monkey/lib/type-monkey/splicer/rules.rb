unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/wrapper'
  require 'type-monkey/splicer'
  require 'type-monkey/splicer/ops'
end

module TypeMonkey
  module Splicer
    # Wrapper around a merge rule definition
    class Rules
      # Parse the JSON tree in +definitions+ and create applyable rules from it.
      def initialize( definitions, mapping = { 'objects' => {}, 'paths' => {} } )
        @rules = {}
        @mapping = mapping

        definitions.each do |defn|
          next unless defn.has_key? 'type'
          next unless defn.has_key? 'path'
          next unless defn.has_key? 'splice'

          unless %w(original modified immutable inherit).include? defn['splice']
            raise TypeMonkey::Splicer::Error, "Unsupported splice key '#{defn['splice']}'."
          end

          rule = {
            :path   => check_path(defn['path'], @mapping['paths'] || {}),
            :splice => defn['splice'].to_sym,
            :when   => parse_when( defn['when'] )
          }

          type = @mapping['objects'][defn['type']] || defn['type']
          @rules[type] ||= []
          @rules[type] << rule
        end
      end

      # Find a rule applying to this +splicer+.
      # This will check the parsed rules for the path returned by +splicer+
      # and if a matching path or wildcard is found return the required merge
      # behavior.
      # @param splicer [TypeMonkey::CoreSplicer]
      def find( splicer )
        return nil if splicer.nil? or @rules[splicer.type_name].nil?

        # check for a 100% match
        @rules[splicer.type_name].each do |rule|
          next unless rule[:path] == splicer.path

          if rule[:when].eval( splicer )
            return rule[:splice]
          end
        end

        # check for array wildcard matches
        @rules[splicer.type_name].each do |rule|
          path = rule[:path].gsub( /\[\s*\*\s*\]/, '[\d+]' ).gsub( /(\[|\])/, '\\\\\\1')
          next unless splicer.path =~ /#{path}/

          if rule[:when].eval( splicer )
            return rule[:splice]
          end
        end

        nil
      end

      def reverse_path( path )
        check_path( path, @mapping['paths'] || {} )
      end

      def mapped_path( path )
        check_reverse_path( path, @mapping['paths'] || {} )
      end

      private

      # @private
      # Check for and return a mapping for +path+
      # @param path [String] The unmapped path string
      # @param mapping [Hash<String,String>] A dictionary of path mappings.
      # @return The mapped path or in case there is no mapping the original.
      def check_path( path, mapping )
        res = path.clone
        # collect all array indices and replace them with
        # %idxN
        indices = {}
        path = path.gsub(/(?<=\[)(\d+|\*)\s*(?=\])/) do |index|
          key = "%idx#{indices.keys.size}"
          if index == '*'
            indices[key] = index
          else
            indices[key] = "#{index.to_i - 1}"
          end
          key
        end

        # check if a mapping the that path exists
        if mapping.has_key? path
          res = mapping[path].clone
          # if so, re-insert the indices at the correct
          # positions inside the path
          indices.each_pair do |key,index|
            res.gsub!( key, index )
          end
        end
        res
      end

      # Return the reverse-mapping for a +path+
      # @param mapping [Hash<String,String>] A dictionary of path mappings.
      # @return The mapped path or in case there is no mapping the original.
      def check_reverse_path( path, mapping )
        @reverse_map ||= begin
          reverse = {}
          mapping.keys.each do |key|
            reverse[mapping[key]] = key
          end
          reverse
        end
        res = path.clone
        # collect all array indices and replace them with
        # %idxN
        indices = {}
        path = path.gsub(/(?<=\[)(\d+|\*)\s*(?=\])/) do |index|
          key = "%idx#{indices.keys.size}"
          if index == '*'
            indices[key] = index
          else
            indices[key] = "#{index.to_i + 1}"
          end
          key
        end

        # check if a mapping the that path exists
        if @reverse_map.has_key? path
          res = @reverse_map[path].clone
          # if so, re-insert the indices at the correct
          # positions inside the path
          indices.each_pair do |key,index|
            res.gsub!( key, index )
          end
        end
        res
      end

      # @private
      # Parse a 'when:' block and create the LogicOps and ValueOps it defines.
      # @return [LogicOp|ValueOp] The top-level operation defined by 'when:'.
      # @return [TrueOp] A true-noop if 'when:' is empty / nil.
      def parse_when( op )
        if op.nil?
          Ops::TrueOp.new
        else
          unless op.is_a? Array or op.size < 2
            raise TypeMonkey::Splicer::Error, "Malformed when condition '#{op}'."
          end

          begin
            args = []
            op[1..-1].each do |arg|
              if arg.is_a? Array
                args << parse_when( arg )
              else
                args << arg
              end
            end
          rescue TypeMonkey::Splicer::Error => e
            raise TypeMonkey::Splicer::Error, "While parsing when condition '#{op}':\n... #{e.message}"
          end

          case op[0]
            when 'and', 'or'
              Ops::LogicOp.new( op[0], *args )
            when '==', '~=', '/=', '<=', '>=', '<', '>'
              Ops::ValueOp.new( op[0], *args[0..1] )
            else
              raise TypeMonkey::Splicer::Error, "Malformed when condition '#{op}'."
          end
        end
      end
    end
  end
end

