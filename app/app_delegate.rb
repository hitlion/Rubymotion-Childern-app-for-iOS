class AppDelegate < PM::Delegate
  include Crescentia::Fixtures
  # include HockeyKit support if it's compiled in
  include AppDelegateHockeyKit if defined?(AppDelegateHockeyKit)

  tint_color '#ffffff'.uicolor

  def on_load( app, options )
    return if RUBYMOTION_ENV == 'test'

    # Hook up HockeyKit (if this build supports it)
    if self.respond_to? :setupHockey
      self.setupHockey
    end

    # Add the required protocols to our Ruby classes
    Babbo::JSBridge::inject_protocols()

    open StoryListScreen.new( nav_bar: true )

    # FIXME: port this to MotionKit?
    UINavigationBar.appearance.barTintColor = '#f9bc34'.uicolor
    UINavigationBar.appearance.setTitleTextAttributes( { NSForegroundColorAttributeName => '#ffffff'.uicolor } )
  end
end

