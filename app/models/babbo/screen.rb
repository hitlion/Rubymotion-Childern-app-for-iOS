module Babbo
  class Screen
    include Babbo::Actionable

    attr_reader :id, :name, :objects, :path
    attr_accessor :scene_node

    # Initialize the model instance from the parsed JSON data.
    # @param data [Hash] The parsed JSON data
    # @param parent [String] The path specification up to the parent object.
    def initialize( data, parent=nil )
      @id = data['screen_id'].to_i
      @name = data['screen_name'].to_s
      @path = "#{parent || ''}:screen[#{@id}]"
      @objects = ( data['objects'] || [] ).map { |obj| Babbo::Object.new( obj, @path ) }

      parse_slots( data['screen_slot'] || [] )
      parse_events( data['screen_event'] || {}, %w(at_load at_next) )
    end

    # Return a hash of objects and paths starting at this model instance.
    # @returns [Hash<String,Object>] A hash for all paths beneath this element.
    def paths()
      @paths ||= begin
        paths = { @path => self }
        @objects.each { |obj| paths[obj.path] = obj }
        paths
      end
    end
  end
end
