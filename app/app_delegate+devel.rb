module AppDelegateHockeyKit
  # HockeyKit extensions
  def setupHockey
    mp_l( 'Initializing HockeyKit' )
    BWHockeyManager.sharedHockeyManager.updateURL = "https://hockey.bitspin-productions.net"
    BWHockeyManager.sharedHockeyManager.delegate = self

    #BWHockeyManager.sharedHockeyManager.loggingEnabled = true
    BWHockeyManager.sharedHockeyManager.alwaysShowUpdateReminder = true
    BWHockeyManager.sharedHockeyManager.checkForUpdateOnLaunch = true
  end

  # HockeyKit delegate
  def connectionOpened
    mp_l( 'HockeyKit - connection opened')
    UIApplication.sharedApplication.networkActivityIndicatorVisible = true
  end

  def connectionClosed
    mp_l( 'HockeyKit - connection closed')
    UIApplication.sharedApplication.networkActivityIndicatorVisible = false
  end
end
