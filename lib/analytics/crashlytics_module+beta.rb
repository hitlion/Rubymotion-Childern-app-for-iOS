# Fabric / Crashlytics integration helper
module CrashlyticsIntegration
  # Setup the required Fabric / Crashlytics API integration
  def setupCrashlytics
    return if device.is_simulator?

    lp 'Initializing Crashlytics'
#    Crashlytics.sharedInstance.delegate = self
    Fabric.with([ Crashlytics.sharedInstance ])
  end

  def crashlyticsDidDetectReportForLastExecution(report, completionHandler: handler)
    unless @did_show_crash_notice
      @did_show_crash_notice = true

      Dispatch::Queue.main.async do
        app.alert(title: "Crashlytics", message: "Babbo ist beim letzten start abgestürzt. Sende Crashreport...")
      end
    end

    NSOperationQueue.mainQueue.addOperationWithBlock(->{ handler.call(true) }.weak!)
  end
end

