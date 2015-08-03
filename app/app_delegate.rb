class AppDelegate < PM::Delegate
  # include Crescentia::Fixtures
  # include HockeyKit support if it's compiled in
  include AppDelegateHockeyKit if defined?(AppDelegateHockeyKit)
  include AppDelegateCrashlytics if defined?(AppDelegateCrashlytics)

  tint_color '#ffffff'.uicolor

  def on_load( app, options )
    return if RUBYMOTION_ENV == 'test'

    # Hook up HockeyKit (if this build supports it)
    self.setupHockey if self.respond_to? :setupHockey
    # Hook up Crashlytics (also, only if supported)
    self.setupCrashlytics if self.respond_to? :setupCrashlytics

    # Add the required protocols to our Ruby classes
    Babbo::JSBridge::inject_protocols()

    open StoryListScreen.new( nav_bar: true, nav_controller: AutoRotatingNavigationController )

    # FIXME: port this to MotionKit?
    UINavigationBar.appearance.barTintColor = '#f9bc34'.uicolor
    UINavigationBar.appearance.setTitleTextAttributes( { NSForegroundColorAttributeName => '#ffffff'.uicolor } )
  end
end

