module Story
  # A wrapper around a single screen.
  class Screen
    include Story::SlotsMixin
    include Story::AttributeValidationMixin

    validation_scope :screen

    has_events :at_load, :at_next

    attr_reader :id, :path, :changes, :new_changes
    attr_accessor :name, :objects

    # Initialize a new Screen instance
    #
    # @param [String] parent_path The document path of the screns parent.
    def initialize( parent_path )
      @id      = -1
      @name    = 'undefined'
      @valid   = false
      @path    = "#{parent_path}:screen[-1]"
      @changes = []
      @new_changes = false
    end

    # Check if this screen is valid.
    # A freshly created screen is always invalid and can only become
    # valid once it's {#load} method was successfully called.
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
    #   initialized by calling {#load} before.
    def load( description )
      return false if valid?

      validate_attributes(description, :screen) do |desc|

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

    ## mark: Change tracking

    # @private
    # Create a copy of the object matching path
    # @param path A string specifying an object path
    def dup_object(path)
      object = @objects.find { |o| o.path == path }
      return false if object.nil?

      new_id     = @objects.length + 1
      new_object = Marshal.load(Marshal.dump(object))
      new_object.instance_eval do
        @id = new_id
      end
      new_object.fix_path(@path)
      @objects << new_object
      @changes << object.path
      modified(true)
      true
    end

    def fix_path( parent_path, recursive=false )
      @path = "#{parent_path}:screen[-1]"
      @path.gsub!(/:screen\[[^\]]*\]$/, ":screen[#{@id}]")

      if recursive
        @objects.each { |s| s.fix_path(@path) }
      end
    end

    def modified(value)
      @new_changes = value
    end
  end
end

