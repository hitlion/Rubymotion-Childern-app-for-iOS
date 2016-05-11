module AppsFlyerIntegration

  def setupAppsFlyer
    return if device.is_simulator?

    NSLog ('Initializing AppsFlyer...')
    AppsFlyerTracker.sharedTracker.appsFlyerDevKey = '4Eya4CzLqUrYvvsya92dYb'
    AppsFlyerTracker.sharedTracker.appleAppID = '1097884638'
    AppsFlyerTracker.sharedTracker.trackAppLaunch
  end
end