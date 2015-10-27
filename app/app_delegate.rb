class AppDelegate < PM::Delegate
  status_bar true, animation: :fade
  tint_color rmq.color.white

  include CrashlyticsIntegration if defined? CrashlyticsIntegration

  def on_load( app, options )
    return if RUBYMOTION_ENV == 'test'

    self.setupCrashlytics if self.respond_to? :setupCrashlytics

    open StartScreen.new(nav_bar: false , nav_controller: AutoRotatingNavigationController)

    # NOTE: this is not in the RMQ samples but it's required for appearance.rb.
    rmq.all.reapply_styles
  end

  def application(application, willChangeStatusBarOrientation: new_orientation, duration: d)
    device.orientation = new_orientation
  end
end

