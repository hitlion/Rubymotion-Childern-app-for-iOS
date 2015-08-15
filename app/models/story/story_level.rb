module Story
  # A wrapper around the documents levels.
  # Access to all screens in a level as avilable using the +screens+ property.
  class Level
    #
    # TODO: track changes to the screens array
    #
    include Story::AttributeValidationMixin

    validation_scope :level

    attr_reader :id
    attr_accessor :screens

    # Initialize a new Level instance
    def initialize
      @id      = -1
      @valid   = false
      @path    = ':level[-1]'
    end

    # Check if this level is valid.
    # A freshly created level is always invalid and can only become
    # valid once it's +load+ method was successfully called.
    def valid?
      @valid
    end

    # Load the level attributes from the +Hash+ in +description+.
    #
    # All attributes will be validated, type converted and
    # - where appropriate and required - replaced with default values.
    #
    # @param [Hash] description A +Hash+ containing the initial values
    #   for this levels properties.
    # @return [Boolean] true if the level was initialized successfully.
    #   false if the attributes where invalid or the level was already
    #   initialized by calling +load+ before.
    def load( description )
      return false if valid?

      validate_attributes(description, :level) do |desc|
#       {:level_id => { :required => true, :as => :to_i },
#        :screens  => { :default  => [] }}) do |desc|

        @id      = desc[:level_id]
        @screens = []

        # now that @id is available update our @path
        @path.gsub!(/:level\[[^\]]*\]$/, ":level[#{@id}]")

        desc[:screens].each_with_index do |screen_desc, n|
          screen = Story::Screen.new(@path)
          if screen.load(screen_desc)
            @screens << screen
          else
            @validation_errors += screen.validation_errors.map do |err|
              "screen[#{n}]: #{err}"
            end
            screen = nil
          end

          # free unused memory if we're invalid anyway..
          @screens = [] unless validation_errors.empty?
        end
      end

      @valid = true if validation_errors.empty?
      valid?
    end
  end
end

