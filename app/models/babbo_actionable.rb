module Babbo
  module Actionable
    def parse_events( events, filter )
      @events = events.select { |n,s| filter.include? n }
    end

    def parse_slots( slots )
      @slots = slots.map { |slot| Babbo::Slot.new( slot ) }
    end

    def emit( event )
      return unless @events.has_key? event
      return unless @slots.has_key? @events[event]

      # TODO: - resolve the slot object content
      #       - instantiate a headless webkit instance
      #       - inject the required native<->js-object bridges
      #       - execute the action
      PM::logger.info( "Actionable.emit( '#{event}' => #{@events[event]} )" )
    end
  end
end

