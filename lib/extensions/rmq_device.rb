# @private
module RubyMotionQuery
  # RMQs shorthand for UIDevice.currentDevice
  class Device
    class << self
      # Return the real pixel width for the current screen
      # taking retina scale factors into account.
      # @return [Float] The physical pixel width
      def scaled_width
        screen_width * screen.scale
      end

      # Return the real pixel height for the current screen
      # taking retina scale factors into account.
      # @return [Float] The physical pixel height
      def scaled_height
        screen_height * screen.scale
      end

      # Workaraund to get {simulator?} working on iOS9
      # @note This can be removed once https://github.com/infinitered/rmq/issues/293
      #   is closed.
      def is_simulator?
        @_is_simulator = !(NSBundle.mainBundle.bundlePath.start_with? '/var/') if @_is_simulator.nil?
        @_is_simulator
      end
    end
  end
end

