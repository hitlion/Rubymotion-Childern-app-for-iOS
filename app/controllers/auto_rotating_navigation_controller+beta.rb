# UINavigationController with proper support for forced view orientations
# Thanks go out to: http://stackoverflow.com/a/14402965
class AutoRotatingNavigationController < PM::NavigationController
  # hook into pushViewController and enable displaying of the
  # HockeyKit UUID (identifier for vendor)
  def pushViewController( vc, animated: an )
    super

    unless navigationBar.nil?
      rmq(navigationBar).off.on(:tap, taps_required: 2) do
        uuid = UIDevice.currentDevice.identifierForVendor
        app.alert(title: "Hockey UUID",
                  message: "beef#{uuid.UUIDString.gsub(/-/, '0')}")
      end
    end
  end
end

