module JavaScript
  # Global methods exported to JavaScriptCore as '$'
  class Global
    include JavaScript::BridgeMixin

    javascript_export :b_b_v_j_s_bridged_global

    # Log a message to the internal logging view
    #
    # @param [String] message The message to be logged.
    def log( message )
      mp "JavaScript: #{message}", force_color: :purple
    end

    # Sleep the current thread for a specific number of milliseconds.
    #
    # @param [Float] msec The number of milliseconds to wait
    def msleep( msec )
      NSThread.sleepForTimeInterval(msec / 1000.0)
    end

    # Return a copy of +array+ with it's items shuffled
    #
    # @param [Array] array The array to shuffle
    # @return [Array] A new array with the same contents as +array+
    #   but with a different item order.
    def shuffle( array )
      array.shuffle
    end
  end
end

