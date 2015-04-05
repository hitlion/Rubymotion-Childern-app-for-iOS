module Babbo
  class Screen
    include Babbo::Actionable

    attr_reader :id, :name, :objects

    def initialize( data )
      @id = data['screen_id'].to_i
      @name = data['screen_name'].to_s
      @objects = ( data['objects'] || [] ).map { |obj| Babbo::Object.new( obj ) }

      parse_slots( data['screen_slot'] || [] )
      parse_events( data['screen_event'] || {}, %w(at_load at_next) )
    end
  end
end
