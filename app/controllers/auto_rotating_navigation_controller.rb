# UINavigationController with proper support for forced view orientations
# Thanks go out to: http://stackoverflow.com/a/14402965
class AutoRotatingNavigationController < PM::NavigationController
  # @private
  def shouldAutorotate
    self.topViewController.shouldAutorotate
  end

  # @private
  def supportedInterfaceOrientations
    self.topViewController.supportedInterfaceOrientations
  end

  # @private
  def preferredInterfaceOrientationForPresentation
    self.topViewController.preferredInterfaceOrientationForPresentation
  end
end

