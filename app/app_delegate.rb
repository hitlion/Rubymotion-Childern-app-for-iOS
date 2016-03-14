class AppDelegate < PM::Delegate
  status_bar true, animation: :fade
  tint_color rmq.color.white

  include CrashlyticsIntegration if defined? CrashlyticsIntegration
  include Devmode if defined? Devmode

  def on_load( app, options )

    UIApplication.sharedApplication.setStatusBarOrientation(UIInterfaceOrientationLandscapeLeft , animated: false)

    return if RUBYMOTION_ENV == 'test'

    self.setupDevmode if self.respond_to? :setupDevmode
    self.setupCrashlytics if self.respond_to? :setupCrashlytics

    root = Dir.system_path(:documents)
    bundles_data =  NSBundle.mainBundle.pathForResource('data/Bundles', ofType: nil)
    backend_data =  NSBundle.mainBundle.pathForResource('data/Backend', ofType: nil)

    if(Dir.exist?(root))
      # only work on device not in the sim.
      unless Dir.exist?(File.join(root, "Bundles"))
        lp "App: local bundles folder doesn't exist, copy app included folder to root directory"
        dest = File.join(root, 'Bundles')
        NSFileManager.defaultManager.copyItemAtPath(bundles_data, toPath: dest, error: nil)
      end

      unless Dir.exist?(File.join(root, "Backend"))
        lp "App: local backend folder doesn't exist, copy app included folder to root directory"
        dest = File.join(root, 'Backend')
        NSFileManager.defaultManager.copyItemAtPath(backend_data, toPath: dest, error: nil)
      end
    end

    if defined? Devmode
      StartScreen.next_screen = self.devmode_start_screen || nil
    end

    open StartScreen.new

    # NOTE: this is not in the RMQ samples but it's required for appearance.rb.
    rmq.all.reapply_styles
  end

  def application(application, willChangeStatusBarOrientation: new_orientation, duration: d)
    device.orientation = new_orientation
  end

end

