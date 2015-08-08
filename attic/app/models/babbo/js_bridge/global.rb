module Babbo
  module JSBridge
    # Global method proxy
    class Global
      def initialize()
      end 

      def log( message )
        SystemLogView.log_jscript( "[JavaScriptLog]: #{message}" )
        NSLog( "[BBVJSBridged.log]: #{message}" )
      end

      def msleep( millisec )
        NSThread.sleepForTimeInterval( millisec / 1000.0 )
      end

      def shuffle( array )
        array.shuffle
      end
    end
  end
end
