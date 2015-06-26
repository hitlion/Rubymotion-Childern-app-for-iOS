# UINavigationController with proper support for forced view orientations
# Thanks go out to: http://stackoverflow.com/a/14402965
class AutoRotatingNavigationController < PM::NavigationController
  def shouldAutorotate
    self.topViewController.shouldAutorotate
  end

  def supportedInterfaceOrientations
    self.topViewController.supportedInterfaceOrientations
  end
end

