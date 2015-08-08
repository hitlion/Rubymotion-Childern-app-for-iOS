module Babbo
  class Object
    include Babbo::Actionable

    attr_reader :id, :name, :type, :processable,
                :size, :layer, :alpha, :path
    attr_accessor :position, :content, :modifiable

    # Initialize the model instance from the parsed JSON data.
    # @param data [Hash] The parsed JSON data
    # @param parent [String] The path specification up to the parent object.
    def initialize( data, parent=nil )
      @id = data['object_id'].to_i
      @name = data['object_name'].to_s
      @type = map_object_type( data['object_type'] )
      @processable = map_object_processable( data['object_processable'] )
      @content = data['object_content']

      @position = CGPointMake( data['object_attribute']['position_x'].to_f,
                               data['object_attribute']['position_y'].to_f )
      @size = CGSizeMake( data['object_attribute']['size_x'].to_f,
                          data['object_attribute']['size_y'].to_f )
      @layer = data['object_attribute']['layer'].to_i
      @alpha = data['object_attribute']['transparency'].to_f
      @path = "#{parent || ''}:object[#{@id}]"

      parse_slots( data['object_slot'] || [] )
      parse_events( data['object_event'] || {},
                    %w(on_click on_swipe at_start at_end) )

      @modifiable = false
    end

    private

    # Map a string to an object type constant
    # @param type [String] The object type as a string
    # @return [Symbol] A symbol matching +type+
    def map_object_type( type )
      if %w(audio video picture).include? type
        type.to_sym
      else
        raise Babbo::Error, "Invalid object_type '#{type}'"
      end
    end

    # Map a string to a precossable constant
    # @param type [String] The objects processable string
    # @return [Symbol] A symbol matching +processable+
    def map_object_processable( processable )
      if %w(local remote).include? processable
        processable.to_sym
      else
        processable = :remote
      end
    end
  end
end

