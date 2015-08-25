# HockeyKit ad-hoc distribution helper
module HockeyKitIntegration
  # Setup HockeyKit integration.
  def setupHockeyKit
    return if device.is_simulator?

    lp 'Initalizing HockeyKit'
    # generic setup
    BWHockeyManager.sharedHockeyManager.updateURL = 'https://hockey.bitspin-productions.net'
    BWHockeyManager.sharedHockeyManager.delegate = self
    # update behavior
    BWHockeyManager.sharedHockeyManager.alwaysShowUpdateReminder = true
    BWHockeyManager.sharedHockeyManager.showDirectInstallOption = true
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

  # @private
  # callback to get a unique device identifier
  def customDeviceIdentifier
    if app.development? || app.ad_hoc_release?
      uuid = UIDevice.currentDevice.send(:identifierForVendor)
      return uuid.UUIDString unless uuid.nil?
    end
    nil
  end
end

