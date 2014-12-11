class AppDelegate
  include Crescentia::Fixtures

  def application( application, didFinishLaunchingWithOptions:launchOptions )
    return true if RUBYMOTION_ENV == 'test'

    story_list_view_controller = StoryListViewController.alloc.init
    navigation_controller = UINavigationController.alloc.init
    navigation_controller.pushViewController( story_list_view_controller, animated: false )

    @window = UIWindow.alloc.initWithFrame( UIScreen.mainScreen.bounds )
    @window.rootViewController = navigation_controller
    @window.makeKeyAndVisible
    true
  end
end
