# Promotion ditched their logger in favor of
# MotionPrint.. add some helpers to ease life
module MotionPrint
  class << self
    def simulator?
      @simulator ||= ( !(UIDevice.currentDevice.model =~ /simulator/i).nil? or NSBundle.mainBundle.infoDictionary.has_key? 'SPEC_HOST_PATH')
    end

    def use_nslog
      @use_nslog = true
    end

    def use_nslog?
      !@use_nslog.nil?
    end
  end
end

module Kernel
  def mp_l( message )
    if MotionPrint.use_nslog?
      NSLog( "[INFO] #{message}" )
    else
      return unless MotionPrint.simulator?
    end
    mp "[INFO] #{message}", force_color: :green
  end

  def mp_d( message )
    if MotionPrint.use_nslog?
      NSLog( "[DEBUG] #{message}" )
    else
      return unless MotionPrint.simulator?
    end
    mp "[DEBUG] #{message}", force_color: :yellow
  end

  def mp_e( message )
    if MotionPrint.simulator? and ! MotionPrint.use_nslog?
      mp "[ERROR] #{message}", force_color: :red
    else
      NSLog( "[ERROR] #{message}")
    end
  end
end

