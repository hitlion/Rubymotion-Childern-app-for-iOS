# HockeyKit ad-hoc distribution helper
module HockeyKitIntegration
  # Setup HockeyKit integration.
  def setupHockeyKit
    return if device.simulator?

    mp 'Initalizing HockeyKit'
    # generic setup
    BWHockeyManager.sharedHockeyManager.updateURL = 'https://hockey.bitspin-productions.net'
    BWHockeyManager.sharedHockeyManager.delegate = self
    # update behavior
    BWHockeyManager.sharedHockeyManager.alwaysShowUpdateReminder = true
    BWHockeyManager.sharedHockeyManager.checkForUpdateOnLaunch = true
  end

## HockeyKit delegate methods (all optional)

  # @private
  # callback when HockeyKit starts checking for updates
  def connectionOpened
    rmq.animations.start_spinner
  end

  # @private
  # callback when HockeyKit finishes checking for updates
  def connectionClosed
    rmq.animations.stop_spinner
  end
end

