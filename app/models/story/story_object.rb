module Story
  # A wrapper around a single object inside a screen.
  # All vital properties can be accessed via attributes.
  # Changes to the writeable attributes are traced and can be
  # monitored using the {#changes} attribute.
  class Object
    include Story::SlotsMixin
    include Story::AttributeValidationMixin

    validation_scope :object
    validation_scope :object_attribute

    has_events :at_start, :at_end, :on_click, :on_swipe,
               :start_moving, :end_moving, :new_position

    attr_reader :id, :type, :processable, :resize, :moveable, :path,
                :changes, :mask, :new_changes
    attr_accessor :name, :content, :position, :size, :layer, :transparency

    # Initialize a new Object instance
    #
    # @param [String] parent_path The document path of the objects parent.
    def initialize( parent_path )
      @id      = -1
      @name    = 'undefined'
      @changes = {}
      @valid   = false
      @path    = "#{parent_path}:object[-1]"
      @new_changes = false
    end

    # Check if this object is valid.
    # A freshly created object is always invalid an can only become
    # valid once it's {#load} method was successfully called.
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
    #   initialized by calling {#load} before.
    def load( description )
      return false if valid?

      validate_attributes(description, :object) do |desc|

        @id           = desc[:object_id]
        @name         = desc[:object_name]
        @type         = desc[:object_type]
        @processable  = desc[:processable]
        @content      = desc[:object_content]
        @mask         = desc[:object_mask]

        # now that @id is available update our @path
        @path.gsub!(/:object\[[^\]]*\]$/, ":object[#{@id}]")

        # +object_attribute+ is a +Hash+ in it's own and deserves
        # it's own nested validation (also it has optionals..).
        validate_attributes(desc[:object_attribute], :object_attribute) do |attribs|

          @position     = CGPoint.new(attribs[:position_x], attribs[:position_y])
          @size         = CGSize.new(attribs[:size_x], attribs[:size_y])
          @layer        = attribs[:layer]
          @transparency = attribs[:transparency]
          @resize       = attribs[:resize]
          @moveable     = attribs[:moveable]
        end

        parse_events(desc[:object_event])
        parse_slots(desc[:object_slot])
      end

      @valid = true if validation_errors.empty?
      valid?
    end

    ## mark: Change tracking

    # @private
    # Track modifications to the objects {#name} property
    def name=( new_name )
      @changes[:object_name] ||= { :value => nil, :original => @name }
      @changes[:object_name][:value] = new_name
      modified(true)
      @name = new_name
    end

    # @private
    # Track modifications to the objects {#content} property
    def content=( new_content )
      @changes[:object_content] ||= { :value => nil, :original => @content }
      @changes[:object_content][:value] = new_content
      lp @changes[:object_content]
      modified(true)
      @content = new_content
    end

    # @private
    # Track modifications to the objects {#position} property
    def position=( new_position )
      @changes[:position_x] ||= { :value => nil, :original => @position.x }
      @changes[:position_y] ||= { :value => nil, :original => @position.y }
      @changes[:position_x][:value] = new_position.x
      @changes[:position_y][:value] = new_position.y
      modified(true)
      @position = new_position
    end

    # @private
    # Track modifications to the objects {#size} property
    def size=( new_size )
      @changes[:size_x] ||= { :value => nil, :original => @size.width }
      @changes[:size_y] ||= { :value => nil, :original => @size.height }
      @changes[:size_x][:value] = new_size.width
      @changes[:size_y][:value] = new_size.height
      modified(true)
      @size = new_size
    end

    # @private
    # Track modifications to the objects {#layer} property
    def layer=( new_layer )
      @changes[:layer] ||= { :value => nil, :original => @layer }
      @changes[:layer][:value] = new_layer
      modified(true)
      @layer = new_layer
    end

    # @private
    # Track modifications to the objects {#transparency} property
    def transparency=( new_transparency )
      @changes[:transparency] ||= { :value => nil, :original => @transparency }
      @changes[:transparency][:value] = new_transparency
      modified(true)
      @transparency = new_transparency

    end

    # @private
    # Fix the objects {#path} after copying it
    def fix_path( parent_path )
      @path = "#{parent_path}:object[-1]"
      modified(true)
      @path.gsub!(/:object\[[^\]]*\]$/, ":object[#{@id}]")
    end

    def modified(value)
      @new_changes = value
    end
  end
end

