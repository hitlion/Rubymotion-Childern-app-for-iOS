module Story
  module Changelog
    # A single splice rule
    class Rule
      attr_reader :path, :when, :splice, :distance

      # Create a new +Rule+ instance from parsed data.
      # @param [Hash] data A rule definition parsed from JSON or YAML
      # @option [String] data :path A path inside the story bundle.
      #   Arrays like 'level[]' can be subscripted directly 'level[1]' or as
      #   wildcard 'level[*]'. Path can be specified down to object property
      #   granularity e.g. ':level[1]:screen[1]:object[1]:object_attributes:position_x'
      # @option [Symbol] data :splice The splice action to take.
      #   One of ':accept' or ':reject' to allow or prevent modifications on 
      #   +:path+.
      # @option [Array] data :when A list of value and logic operations to
      #   decide if the rule applies to an object matching +:path+.
      #   This key is optional and if not specified defaults to a +true+-op.
      def initialize( data )
        @path     = data[:path] || 'invalid'
        @splice   = (data[:splice] || 'invalid').to_sym
        @valid    = true

        unless [:accept, :reject].include? @splice
          @valid = false
        end

        @when     = parse_op(data[:when] || [])
        @distance = 0

        @regex    = Regexp.new("^#{@path.gsub(/([\[\]])/, '\\\\\1').gsub(/\*/, '\\d+')}$")
      end

      # Check if this rule uses exact matching.
      # @return [Boolean] +true+ for rules without wildcards, +false+ otherwise
      def is_exact?
        @path.include?('*') == false
      end

      # Check if this rule is valid
      # @return [Boolean] +true+ if all required keys exist and all operators
      #   used inside the optional +:when+ clause are valid.
      #   +false+ otherwise.
      def valid?
        @valid
      end

      # Evaluate this rule for a given story path
      #
      # This method will evaluate the rolue for a given story path
      # and return whether it matches or not.
      # If the rule doesn't match the whole path down to the lowest level.
      # (denoted by the last part behind the rightmost ':') it will try
      # to match "one level up the chain" by removing the rightmost path
      # element and attempting the match again.
      #
      # If the rule matches the number of removed path elements can be
      # queried by accessing the +distance+ property.
      # A distance of 0 indicates a complete match.
      # A distance of 1 indicates a match after removing on path element from
      # the right and so on.
      #
      # (The lowest possible match therefore is ':level[x]')
      #
      # @param [Story::Changelog::ValueMapper] mapper A +ValueMapper+ instance
      # @param [String] path The story path to match against.
      # @return +true+ if this rule matches +path+, +false+ otherwise.
      def eval( mapper, path )
        @distance = 0

        begin
          if @regex.match(path)
            lp "#{self} matched path '#{path}', distance: #{@distance} - evaluating.."
            if @when.eval(mapper, path)
              return true
            end
          end

          @distance += 1
          path = path.split(':')[0..-2].join(':')
        end until path.empty?
        false
      end

      # @private
      def to_s
        "<Rule '#{@path}'>"
      end

      private

      # Recursively parse a list of arrays and generate either
      # logic, value or boolean operations from this list.
      #
      # @param [Array] opdef the +:when+ clause for this rule.
      #   May be +nil+ or +[]+ in which case a {Story::Changelog::Operators::True}
      #   is returned.
      # @returns [Object] the suitable operator instance.
      def parse_op( opdef )
        if opdef.nil? || opdef.empty?
          return Operators::True.new
        end

        unless opdef.is_a? Array and opdef.size >= 2
          @valid = false
          return Operators::False.new
        end

        args = []
        opdef[1..-1].each do |arg|
          if arg.is_a? Array
            args << parse_op(arg)
          else
            args << arg
          end
        end

        case opdef.first
          when 'and', 'or'
            Operators::Logic.new(opdef.first, *args)
          when '==', '~=', '/=', '<=', '>=', '<', '>'
            Operators::Value.new(opdef.first, *args)
        end
      end
    end
  end
end

