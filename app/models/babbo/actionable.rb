module Babbo
  # +Actionable+ a collection of shared methods used among
  # the Babbo model classes to load and execute signals and slots.
  module Actionable
    # parse the events defined for a given JSON object
    # (filtering for supported events).
    # @param events [Hash] The JSON 'events' definition
    # @param filter [Array] A list of events supported by this object.
    def parse_events( events, filter )
      @events = events.select { |n,s| filter.include? n }
    end

    # parse the slots defined for a given JSON object.
    # @param slets [Hash] The JSON 'slots' definition.
    def parse_slots( slots )
      @slots = slots.map { |slot| Babbo::Slot.new( slot ) }
    end

    # execute a given +event+ inside a +story+ object.
    # @param event [String] The name of the event that should be fired.
    # @param story [Babbo::Document] The containing story document.
    # @param concrete_slot [String] The name of a concrete slot that should be
    #   fired instead of +event+ (used internally for +Generic#emit+.
    def emit( event, story, concrete_slot=nil )
      return unless @events.has_key? event or ! concrete_slot.nil?
      if concrete_slot.nil?
        slot = @slots.find { |s| s.name == @events[event] }
      else
        slot = @slots.find { |s| s.name == concrete_slot }
      end
      return if slot.nil?

      # run the actual event execution insida an asynchronous thread
      # managed by GCD (this prevenst things like '$.msleep()' from blocking
      # the main application.
      Dispatch::Queue.new( 'babbo.js-exec' ).async do
        # try to get a lock on the slot and thus mark it as active
        # or fail if it is already locked.
        # (no run of multiple instances at the same time)
        return unless slot.busy.tryLock

        mp_l( "Actionable.emit( '#{event}' => #{@events[event]} )" )

        vm  = JSVirtualMachine.alloc.init
        ctx = JSContext.alloc.initWithVirtualMachine( vm )

        # build JS Bridging proxies..
        slot.variables.each do |var|
          mp_l( "JS: creating proxy for #{var}" )
          target = var[:content].gsub( ':self' , self.path )
          object = story.object_for_path( target )
          if object.nil?
            mp_e( "Could not resolve reference to '#{var[:content]}', abort." )
            ctx = nil
            vm  = nil
            slot.busy.unlock
            return
          end

          # creat a proxy for this object..
          proxy = Babbo::JSBridge::proxy_for_object( object )
          # .. end export it into the JavaScript context
          ctx["$#{var[:name]}"] = proxy
          mp_l( "JS{$#{var[:name]} => #{proxy}}" )
        end

        # .. also inject the current object as '$self'..
        ctx['$self'] = Babbo::JSBridge::proxy_for_object( self )
        # .. and the global methods provided by BBVJSBridgingHelper '$.'
        ctx['$'] = BBVJSBridgingHelper.alloc.init

        ctx.setExceptionHandler( lambda { |c,val| mp_e_js( "JavascriptException: #{val.toString}" ) } )
        ctx.evaluateScript( slot.action )

        ctx = nil
        vm  = nil
        # Free the slot for future execution
        slot.busy.unlock
      end
    end

    def scene_node
      res = nil
      if StoryPlayerScreen.active_instance.scene.name == self.path
        res = StoryPlayerScreen.active_instance.scene
      else
        StoryPlayerScreen.active_instance.scene.enumerateChildNodesWithName( '//*', usingBlock: lambda { |node, stop|
          res = node if node.name == self.path
          stop = true unless res.nil?
        })
      end
      res
    end
  end
end

