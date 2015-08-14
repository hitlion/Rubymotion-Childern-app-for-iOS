module Story
  # A wrapper around a single screen.
  class Screen
    #
    # TODO: track changes to the objects array
    #
    include Story::SlotsMixin
    include Story::AttributeValidationMixin

    has_events :at_load, :at_next

    attr_reader :id, :name
    attr_accessor :objects

    # Initialize a new Screen instance
    #
    # @param [String] parent_path The document path of the screns parent.
    def initialize( parent_path )
      @id      = -1
      @name    = 'undefined'
      @valid   = false
      @path    = "#{parent_path}:screen[-1]"
    end

    # Check if this screen is valid.
    # A freshly created screen is always invalid and can only become
    # valid once it's +load+ method was successfully called.
    def valid?
      @valid
    end

    # Load the screen attributes from the +Hash+ in +description+.
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

      validate_attributes(description, {
        :screen_id     => { :required => true, :as => :to_i },
        :name          => { :required => true, :as => :to_s },
        :objects       => { :default  => [] },
        :screen_event  => { :default  => {} },
        :screen_slot   => { :default  => [] } }) do |desc|

        @id      = desc[:screen_id]
        @name    = desc[:name]
        @objects = []

        # now that @id is available update our @path
        @path.gsub!(/:screen\[[^\]]*\]$/, ":screen[#{@id}]")

        parse_events(desc[:screen_event])
        parse_slots(desc[:screen_slot])

        desc[:objects].each_with_index do |object_desc, n|
          object = Story::Object.new(@path)
          if object.load(object_desc)
            @objects << object
          else
            @validation_errors += object.validation_errors.map do |err|
              "objects[#{n}]: #{err}"
            end
            object = nil
          end

          # free unused memory if we're invalid anyway..
          @objects = [] unless validation_errors.empty?
        end
      end

      @valid = true if validation_errors.empty?
      valid?
    end
  end
end

