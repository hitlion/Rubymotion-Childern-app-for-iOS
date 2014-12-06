class AppDelegate
  include Crescentia::Fixtures

  def application( application, didFinishLaunchingWithOptions:launchOptions )
    @window = UIWindow.alloc.initWithFrame( UIScreen.mainScreen.bounds )
    @window.makeKeyAndVisible
    true
  end
end
