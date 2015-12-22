class AppDelegate < PM::Delegate
  status_bar true, animation: :fade
  tint_color rmq.color.white

  include CrashlyticsIntegration if defined? CrashlyticsIntegration
  include Devmode if defined? Devmode

  def on_load( app, options )
    return if RUBYMOTION_ENV == 'test'

    self.setupDevmode if self.respond_to? :setupDevmode
    self.setupCrashlytics if self.respond_to? :setupCrashlytics

    if defined? Devmode
      StartScreen.next_screen = self.devmode_start_screen || nil
    end

    open StartScreen.new

    # NOTE: this is not in the RMQ samples but it's required for appearance.rb.
    rmq.all.reapply_styles
  end

  def application(application, willChangeStatusBarOrientation: new_orientation, duration: d)
    device.orientation = new_orientation
  end
end

