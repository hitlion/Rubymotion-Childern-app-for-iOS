module AppDelegateHockeyKit
  # HockeyKit extensions
  def setupHockey
    PM::logger.info( 'Initializing HockeyKit' )
    BWHockeyManager.sharedHockeyManager.updateURL = "https://hockey.bitspin-productions.net"
    BWHockeyManager.sharedHockeyManager.delegate = self

    BWHockeyManager.sharedHockeyManager.loggingEnabled = true
    BWHockeyManager.sharedHockeyManager.alwaysShowUpdateReminder = true
    BWHockeyManager.sharedHockeyManager.checkForUpdateOnLaunch = true
  end

  # HockeyKit delegate
  def connectionOpened
    PM::logger.info( 'HockeyKit - connection opened')
    UIApplication.sharedApplication.networkActivityIndicatorVisible = true
  end

  def connectionClosed
    PM::logger.info( 'HockeyKit - connection closed')
    UIApplication.sharedApplication.networkActivityIndicatorVisible = false
  end
end
