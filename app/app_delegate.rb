class AppDelegate < PM::Delegate
  status_bar true, animation: :fade
  tint_color rmq.color.white

  include CrashlyticsIntegration if defined? CrashlyticsIntegration
  include Devmode if defined? Devmode
  include AppsFlyerIntegration if defined? AppsFlyerIntegration

  def on_load( app, options )

    #UIApplication.sharedApplication.setStatusBarOrientation(UIInterfaceOrientationLandscapeLeft , animated: false)

    return if RUBYMOTION_ENV == 'test'

    self.setupDevmode if self.respond_to? :setupDevmode
    self.setupCrashlytics if self.respond_to? :setupCrashlytics
    self.setupAppsFlyer if self.respond_to? :setupAppsFlyer

    root = Dir.system_path(:documents)
    bundles_data =  NSBundle.mainBundle.pathForResource('data/Bundles', ofType: nil)
    backend_data =  NSBundle.mainBundle.pathForResource('data/Backend', ofType: nil)

    if(Dir.exist?(root))
      # only work on device not in the sim.
      unless Dir.exist?(File.join(root, "Bundles"))
        lp "App: local bundles folder doesn't exist, copy app included folder to root directory"
        dest = File.join(root, 'Bundles')
        unless bundles_data.nil?
          NSFileManager.defaultManager.copyItemAtPath(bundles_data, toPath: dest, error: nil)
        end
      end

      dest = File.join(root, 'Backend')
      version = NSBundle.mainBundle.objectForInfoDictionaryKey('CFBundleShortVersionString')

      if NSUserDefaults.standardUserDefaults.stringForKey('de.tuluh_tec.babbo_voco.version') != version.to_s
        NSUserDefaults.standardUserDefaults.setObject(version.to_s, forKey:'de.tuluh_tec.babbo_voco.version')
        NSUserDefaults.standardUserDefaults.synchronize

        if Dir.exist?(dest)
          lp 'App: New Version Delete Old Backend Folder'
          NSFileManager.defaultManager.removeItemAtPath(dest, error:nil)
        end
      end


      unless Dir.exist?(dest)
        lp 'App: Copy backend folder'
        dest = File.join(root, 'Backend')
        unless backend_data.nil?
          NSFileManager.defaultManager.copyItemAtPath(backend_data, toPath: dest, error: nil)
        end
      end
    end

    if defined? Devmode
      StartScreen.next_screen = self.devmode_start_screen || nil
    end

    NSUserDefaults.standardUserDefaults.setBool(true, forKey:'de.tuluh_tec.babbo_voco.show_tutorial')
    NSUserDefaults.standardUserDefaults.synchronize

    open StartScreen.new

    # NOTE: this is not in the RMQ samples but it's required for appearance.rb.
    rmq.all.reapply_styles
  end

  #dont needed
  #def application(application, willChangeStatusBarOrientation: new_orientation, duration: d)
    #device.orientation = new_orientation
  #end
end

