module Babbo
  class Screen
    include Babbo::Actionable

    attr_reader :id, :name, :objects, :path
    attr_accessor :scene_node

    def initialize( data, parent=nil )
      @id = data['screen_id'].to_i
      @name = data['screen_name'].to_s
      @path = "#{parent || ''}:screen[#{@id}]"
      @objects = ( data['objects'] || [] ).map { |obj| Babbo::Object.new( obj, @path ) }

      parse_slots( data['screen_slot'] || [] )
      parse_events( data['screen_event'] || {}, %w(at_load at_next) )
    end

    def paths()
      @paths ||= begin
        paths = { @path => self }
        @objects.each { |obj| paths[obj.path] = obj }
        paths
      end
    end
  end
end
