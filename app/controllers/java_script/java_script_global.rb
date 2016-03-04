module JavaScript
  # Global methods exported to JavaScriptCore as '$'
  class Global

    class << self
      attr_accessor :timer, :timer_slot, :timer_path
    end

    attr_reader :timer
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
    # @param [Hash<Int, String, String>] args The JavaScript arguments.
    # @option args [Int] time The time im milli seconds
    # @option args [String] path the path to the object with the given slot
    # @option args [String] slot The name of the slot
    def onTimedOut(args)
      args = Hash.symbolicate(args)
      if args[:time] && args[:slot] && args[:path]

        if Global.timer
          Global.timer.invalidate
          Global.timer = nil
          Global.timer_path = nil
          Global.timer_slot = nil
        end

        Global.timer_slot = args[:slot]
        Global.timer_path = args[:path]
        time = args[:time].to_i / 1000

        self.log("Globaler Timer wurde mit #{time} Sekunden gestartet")

        Global.timer = NSTimer.scheduledTimerWithTimeInterval(time, target:self, selector:'timer_timed_out', userInfo:nil, repeats: false)
      end
    end

    # Return a copy of +array+ with it's items shuffled
    #
    # @param [Array] array The array to shuffle
    # @return [Array] A new array with the same contents as +array+
    #   but with a different item order.
    def shuffle( array )
      array.shuffle
    end

    # after the global timer expired call the specified slot
    def timer_timed_out
      self.log("Globaler Timer ist abgelaufen")
      JavaScript::Runtime.call_slot(Global.timer_path, Global.timer_slot)
    end

    # cancel the global timer object
    def cancelTimer
      self.log("Globaler Timer wurde abgebrochen")
      if Global.timer
        Global.timer.invalidate
        Global.timer = nil
        Global.timer_path = nil
        Global.timer_slot = nil
      end
    end
  end
end

