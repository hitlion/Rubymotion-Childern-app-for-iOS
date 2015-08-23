# @private
module RubyMotionQuery
  # RMQs shorthand for UIDevice.currentDevice
  class Device
    # Return the real pixel width for the current screen
    # taking retina scale factors into account.
    # @return [Float] The physical pixel width
    def self.scaled_width
      self.screen_width * self.screen.scale
    end

    # Return the real pixel height for the current screen
    # taking retina scale factors into account.
    # @return [Float] The physical pixel height
    def self.scaled_height
      self.screen_height * self.screen.scale
    end
  end
end

