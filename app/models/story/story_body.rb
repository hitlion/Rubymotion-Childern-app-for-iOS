module Story
  # A wrapper around the documents body.
  # This class consists only of the body event / slot definitions
  # and the levels which may be accessed using the +levels+ property.
  class Body
    include Story::SlotsMixin
    include Story::AttributeValidationMixin

    validation_scope :body

    has_events :at_load, :at_end

    attr_accessor :levels

    # Initialize a new Body instance
    def initialize
      @valid   = false
      @path    = ':body'
    end

    # Check if this body is valid.
    # A freshly created body is always invalid and can only become
    # valid once it's +load+ method was successfully called.
    def valid?
      @valid
    end

    # Load the body attributes from the +Hash+ in +description+.
    #
    # All attributes will be validated, type converted and
    # - where appropriate and required - replaced with default values.
    #
    # @param [Hash] description A +Hash+ containing the initial values
    #   for this body properties.
    # @return [Boolean] true if the body was initialized successfully.
    #   false if the attributes where invalid or the body was already
    #   initialized by calling +load+ before.
    def load( description )
      return false if valid?

      validate_attributes(description, :body) do |desc|
#        {:levels     => { :default => [] },
#        :body_event => { :default => {} }, 
#        :body_slot  => { :default => [] }}) do |desc|

        @levels = []

        parse_events(desc[:body_event])
        parse_slots(desc[:body_slot])

        desc[:levels].each_with_index do |level_desc, n|
          level = Story::Level.new
          if level.load(level_desc)
            @levels << level
          else
            @validation_errors += level.validation_errors.map do |err|
              "level[#{n}]: #{err}"
            end
            level = nil
          end

          # free unused memory if we're invalid anyway..
          @levels = [] unless validation_errors.empty?
        end
      end

      @valid = true if validation_errors.empty?
      valid?
    end
  end
end

