class AppDelegate < PM::Delegate
  include Crescentia::Fixtures
  tint_color '#fd8525'.uicolor

  def on_load( app, options )
    return if RUBYMOTION_ENV == 'test'

    # Add the required protocols to our Ruby classes
    Babbo::JSBridge::inject_protocols()

    open StoryListScreen.new( nav_bar: true )

    # FIXME: port this to MotionKit?
    UINavigationBar.appearance.barTintColor = '#fd8525'.uicolor
    UINavigationBar.appearance.setTitleTextAttributes( { NSForegroundColorAttributeName => '#ffffff'.uicolor } )
  end
end
