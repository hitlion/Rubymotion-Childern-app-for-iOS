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
    log = "[INFO] #{message}"
    SystemLogView.log_message( log, :green )

    if MotionPrint.use_nslog?
      NSLog( log )
    else
      return unless MotionPrint.simulator?
    end
    mp log, force_color: :green
  end

  def mp_d( message )
    log = "[DEBUG] #{message}"
    SystemLogView.log_message( log, :yellow )

    if MotionPrint.use_nslog?
      NSLog( log )
    else
      return unless MotionPrint.simulator?
    end
    mp log, force_color: :yellow
  end

  def mp_e( message )
    log = "[ERROR] #{message}"
    SystemLogView.log_message( log, :red )

    if MotionPrint.simulator? and ! MotionPrint.use_nslog?
      mp log, force_color: :red
    else
      NSLog( log )
    end
  end

  def mp_e_js( message )
    log = "[ERROR] #{message}"
    SystemLogView.log_jscript( log, :red )

    if MotionPrint.simulator? and ! MotionPrint.use_nslog?
      mp log, force_color: :red
    else
      NSLog( log )
    end
  end

end

