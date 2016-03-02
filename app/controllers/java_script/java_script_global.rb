module JavaScript
  # Global methods exported to JavaScriptCore as '$'
  class Global

    include JavaScript::BridgeMixin

    javascript_export :b_b_v_j_s_bridged_global

    # Log a message to the internal logging view
    #
    # @param [String] message The message to be logged.
    def log( message )
      lp "JavaScript: #{message}", force_color: :purple, log_js: true
    end

    # Sleep the current thread for a specific number of milliseconds.
    #
    # @param [Float] msec The number of milliseconds to wait
    def msleep( msec )
      NSThread.sleepForTimeInterval(msec / 1000.0)
    end

    # start a timer for the specified time and calls
    # the given slot in the current screen
    # @param [Int] time The time im milli seconds
    # @param [String] The path to the object with the given slot
    # @param [Boolean] Repeat this timer infinite
    # @param [???] slot The slot to call after the timer disband
    def onTimedOut(args)
      args = Hash.symbolicate(args)
      if args[:time] && args[:slot] && args[:path]

        @timer_slot = args[:slot]
        @timer_path = args[:path]
        NSLog('Timer startet')
        if(@timer)
          @timer.invalidate
          @timer = nil
        end
        time = args[:time].to_i / 1000
        @timer = NSTimer.scheduledTimerWithTimeInterval(time, target:self, selector:'timer_timed_out', userInfo:nil, repeats: false)
      end

    end

    def cancelTimer
      @timer.invalidate
      @timer = nil
      @timer_slot = nil
      @timer_path = nil
    end

    # Return a copy of +array+ with it's items shuffled
    #
    # @param [Array] array The array to shuffle
    # @return [Array] A new array with the same contents as +array+
    #   but with a different item order.
    def shuffle( array )
      array.shuffle
    end

    private

    def timer_timed_out
      JavaScript::Runtime.call_slot(@timer_path, @timer_slot)
    end
  end
end

