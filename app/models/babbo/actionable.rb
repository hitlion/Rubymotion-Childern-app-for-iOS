def do_msleep( msec )
  BBVJSBridgingHelper.msleep( msec )
end

module Babbo
  module Actionable
    def parse_events( events, filter )
      @events = events.select { |n,s| filter.include? n }
    end

    def parse_slots( slots )
      @slots = slots.map { |slot| Babbo::Slot.new( slot ) }
    end

    def emit( event, story )
      return unless @events.has_key? event
      slot = @slots.find { |s| s.name == @events[event] }
      return if slot.nil?

      Dispatch::Queue.new( 'babbo.js-exec' ).async do
        return unless slot.busy.tryLock

        PM::logger.info( "Actionable.emit( '#{event}' => #{@events[event]} )" )

        vm  = JSVirtualMachine.alloc.init
        ctx = JSContext.alloc.initWithVirtualMachine( vm )

        # build JS Bridging proxies..
        slot.variables.each do |var|
          PM::logger.info( "JS: creating proxy for #{var}" )
          target = var[:content].gsub( ':self' , self.path )
          object = story.object_for_path( target )
          if object.nil?
            PM::logger.error( "Could not resolve reference to '#{var[:content]}', abort." )
            ctx = nil
            vm  = nil
            slot.busy.unlock
            return
          end

          proxy = Babbo::JSBridge::proxy_for_object( object )

          PM::logger.info( "JS{$#{var[:name]} => #{proxy}}" )
          ctx["$#{var[:name]}"] = proxy
        end

        ctx['$self'] = Babbo::JSBridge::proxy_for_object( self )
        ctx['$'] = BBVJSBridgingHelper.alloc.init

        ctx.setExceptionHandler( lambda { |c,val| PM::logger.error( "JavascriptException: #{val.toString}" ) } )
        ctx.evaluateScript( slot.action )

        ctx = nil
        vm  = nil
        slot.busy.unlock
      end
    end
  end
end

