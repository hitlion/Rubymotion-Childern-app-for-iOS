unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/wrapper'
end

module TypeMonkey
  class Schema
    class Error < StandardError; end

    attr_accessor :types, :validators

    class << self
      def parse( json )
        Schema.new( json )
      end

      protected :new
    end

    def initialize( json )
      @types = nil
      @validators = {}

      # a valid json should contain a hash with type definitions
      # as key-value-pairs
      unless json.is_a? Hash
        raise Schema::Error, 'Expected a dictionary as JSON toplevel element.'
      end

      if json.has_key? '__order'
        for type in json['__order']
          spec = json[type]
          next unless spec.is_a? Hash

          unless spec.has_key? 'type'
            raise Schema::Error, "Definition for type '#{type}' has no 'type' attribute!"
          end

          begin
            Wrapper.register( self, type, spec['type'], spec )
          rescue Wrapper::Error => e
            raise Schema::Error, "Error in schema definition:\n... #{e.message}"
          end
        end
      else
        json.each_pair do |type, spec|
          next unless spec.is_a? Hash

          unless spec.has_key? 'type'
            raise Schema::Error, "Definition for type '#{type}' has no 'type' attribute!"
          end

          begin
            Wrapper.register( self, type, spec['type'], spec )
          rescue Wrapper::Error => e
            raise Schema::Error, "Error in schema definition:\n... #{e.message}"
          end
        end
      end
      self
    end
  end
end

