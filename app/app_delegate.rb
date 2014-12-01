class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame( UIScreen.mainScreen.bounds )
    @window.makeKeyAndVisible
    true
  end

  def cucumber_salat
    puts "Oh, look - salad!"
  end
end
