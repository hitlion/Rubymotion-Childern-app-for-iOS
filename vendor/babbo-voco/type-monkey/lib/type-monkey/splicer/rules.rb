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
      def initialize( definitions )
        @rules = {}

        definitions.each do |defn|
          next unless defn.has_key? 'type'
          next unless defn.has_key? 'path'
          next unless defn.has_key? 'splice'

          unless %w(original modified immutable inherit).include? defn['splice']
            raise TypeMonkey::Splicer::Error, "Unsupported splice key '#{defn['splice']}'."
          end

          rule = {
            :path   => defn['path'],
            :splice => defn['splice'].to_sym,
            :when   => parse_when( defn['when'] )
          }

          @rules[defn['type']] ||= []
          @rules[defn['type']] << rule
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

      private

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
