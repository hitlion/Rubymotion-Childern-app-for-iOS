module Babbo
  class Object
    include Babbo::Actionable

    attr_reader :id, :name, :type, :processable, :content,
                :position, :size, :layer, :alpha

    def initialize( data )
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

      parse_slots( data['object_slot'] || [] )
      parse_events( data['object_event'] || {},
                    %w(on_click on_swipe at_start at_end) )
    end

    private

    def map_object_type( type )
      if %w(audio video picture).include? type
        type.to_sym
      else
        raise Babbo::Error, "Invalid object_type '#{type}'"
      end
    end

    def map_object_processable( processable )
      if %w(local remote).include? processable
        processable.to_sym
      else
        processable = :remote
      end
    end
  end
end

