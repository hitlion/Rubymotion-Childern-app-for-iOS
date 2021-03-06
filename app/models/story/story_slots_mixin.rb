module Story
  module SlotsMixin
    module ClassMixin
      attr_accessor :events

      # Define the valid events for this class.
      # Using the method DSL-Style will create a class property
      # also called {#events} which will contain a +Symbol+ for each
      # valid event.
      #
      # @example
      #   class Foo
      #     include Story::SlotsMixin
      #     events :on_click, :on_swipe
      #   end
      def has_events( *args )
        self.events ||= []
        self.events += args.map { |event| event.to_sym }
      end
    end

    attr_reader :slots, :events

    # Parse a dictionary of event => slot-name mappings
    # and - if the class supports an event - record the
    # mapping in the instance property {#events}.
    #
    # @example Expected syntax for +event_def+
    #  { :event_a => 'slot name', :event_b => 'slot name', ... }
    #
    #
    # @param [Hash<Symbol, String>] event_def A mapping of event
    #   names and assigned slots.
    def parse_events( event_def )
      @events ||= {}
      event_def.each_pair do |name, slot|
        if self.class.events.include? name.to_sym
          @events[name.to_sym] = slot
        else
          @validation_errors ||= []
          @validation_errors << "Undefined event '#{name}'."
          lp "warning: undefined event '#{name}'", force_color: :purple
        end
      end
    end

    # Parse a list of slot definitions.
    # @example Expected syntax for a slot definition
    #   {
    #     :name => 'slot name',
    #     :action => 'multi-line javascript code',
    #     :variables => [
    #       { :name => 'variable name', :content => 'object reference' }
    #     ]
    #   }
    #
    # For each slot a {Story::Slot} instance will be created and populated.
    #
    # @param [Array<Hash>] slot_def A list of slot definitions.
    def parse_slots( slot_def )
      @slots ||= {}
      slot_def.each do |sdef|
        slot = Story::Slot.new
        if slot.load(sdef)
          @slots[slot.name] = slot
        else
          @validation_errors ||= []
          @validation_errors += slot.validation_errors.map do |err|
            "slot['#{slot.name}']: #{err}"
          end
        end
      end
    end

    def self.included( base )
      base.extend(Story::SlotsMixin::ClassMixin)
    end
  end
end

