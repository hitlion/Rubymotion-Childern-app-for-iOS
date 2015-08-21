# Fabric / Crashlytics integration helper
module CrashlyticsIntegration
  # Setup the required Fabric / Crashlytics API integration
  def setupCrashlytics
    return if device.simulator?

    mp 'Initializing Crashlytics'
    Fabric.with([ Crashlytics.sharedInstance ])
  end
end

