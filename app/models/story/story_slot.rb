module Story
  class Slot
    include Story::AttributeValidationMixin

    validation_scope :slot
    validation_scope :slot_variable

    attr_reader :name, :action, :variables

    # Initialize a new Slot instance.
    def initialize
      @name      = 'undefined'
      @action    = ''
      @variables = {}
      @valid     = false
    end

    def valid?
      @valid
    end

    # Load the object attributes from the +Hash+ in +description+.
    #
    # All attributes will be validated, type converted and
    # - where appropriate and required - replaced with default values.
    #
    # @param [Hash] description A +Hash+ containing the initial values
    #   for this objects properties.
    # @return [Boolean] true if the object was initialized successfully.
    #   false if the attributes where invalid or the object was already
    #   initialized by calling +load+ before.
    def load( description )
      return false if valid?


      validate_attributes(description, :slot) do |desc|
        @name      = desc[:name]
        @action    = desc[:action]
        @variables = []

        desc[:variables].each do |var_desc|
          validate_attributes(var_desc, :slot_variable) do |var|
            @variables << var
          end
        end
      end

      @valid = true if validation_errors.empty?
      valid?
    end
  end
end

