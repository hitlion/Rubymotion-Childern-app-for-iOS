# Note on the name of this file - it is necessary to have the '00_' prefix so this is run as first test.
# The reason is that only in this case the tests for 'one window' will work.. I'm investigating this currently.
describe "Application 'Babbo-Voco'" do
  before do
    # this is not nice but the ApplicationDelegate needs RUBYMOTION_ENV != 'test' to instantiate it's content..
    # save the original value and restore it immediately after creating our sharedApplication.
    real_rubymotion_env = Object.spec_fake_motion_env 'development'

    @app = UIApplication.sharedApplication
    @app.delegate.application( @app, didFinishLaunchingWithOptions: {})

    Object.spec_fake_motion_env( real_rubymotion_env )
  end

  after do
  end

  it 'has one window' do
    @app.windows.size.should == 1
  end

  it 'has a navigation controller as it\'s rootViewController' do
    @app.keyWindow.rootViewController.class.should == UINavigationController
  end

  context 'When on the story list screen' do
    before do
      # nothing as currently the story list is the first view in the navigation stack
    end

    after do
    end

    it 'shows a table view' do
      @app.keyWindow.rootViewController.topViewController.class.should == StoryListViewController
    end
  end
end
