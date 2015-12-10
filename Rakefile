# -*- coding: utf-8 -*-
 $:.unshift('/Library/RubyMotion/lib')

require 'rake/task_arguments'

require 'motion/project/template/ios'
require 'motion-yaml'

require 'redcarpet'

## # # in case we get un-catchable exceptions and warnings about compact unwind again
## # # uncomment the following (see: http://stackoverflow.com/a/30733047/128661)
## class Motion::Project::IOSConfig
##   rm_ldflags = instance_method( :ldflags )
##   define_method( :ldflags ) do |platform|
##     rm_ldflags.bind( self ).( platform ) + ' -Wl,-keep_dwarf_unwind -Wl,-no_compact_unwind'
##   end
## end
##

require 'bundler'
Bundler.setup
Bundler.require

# Sources only included in development and test builds.
DEVELOPMENT_ONLY  = Dir.glob('./app/**/*+devel.rb') \
                  + Dir.glob('./lib/**/*+devel.rb')

ADHOC_BETA_ONLY   = Dir.glob('./app/**/*+beta.rb') \
                  + Dir.glob('./lib/**/*+beta.rb')

Motion::Project::App.setup do |app|

  app.files = Dir.glob('./lib/**/*.rb') + app.files
  app.development do
    app.provisioning_profile = ENV['RM_DEV_PROFILE']
    app.codesign_certificate = ENV['RM_DEV_CERTIFICATE']

    # for Spec tests
    app.info_plist['SPEC_HOST_PATH'] = File.absolute_path(Dir.pwd)
  end

  app.release do
    app.provisioning_profile = ENV['RM_PUB_PROFILE']
    app.codesign_certificate = ENV['RM_PUB_CERTIFICATE']

    app.entitlements['get-task-allow'] = false
    #app.entitlements['beta-reports-active'] = true

    # Filter out development helpers
    app.files.select! { |x| true unless DEVELOPMENT_ONLY.include? x }

    unless ENV['staging'] == 'true'
      # also filter out ad-hoc / beta related code
      app.files.select! { |x| true unless ADHOC_BETA_ONLY.include? x }
    end
  end

  app.info_plist['UIAppFonts'] = ['Enriqueta-Bold.otf', 'Enriqueta-Regular.otf']

  # pods used in all configurations
  app.pods do
    pod 'IQAudioRecorderController'
    pod 'zipzap'
  end

  # pods used in staging and ad-hoc releases
  app.pods do
      pod 'Fabric'
      pod 'Crashlytics'
  end

  if ENV['staging'] == 'true' or app.development?

    app.entitlements['get-task-allow'] = true
    #app.entitlements['beta-reports-active'] = true

    if ENV['staging'] == 'true'
      app.entitlements['get-task-allow'] = false
      #app.embed_dsym = true # embedd dsyms in ad-hoc releases

      Motion::Project::App.info('Setup', 'Configuring ad-hoc development build')
      app.provisioning_profile = ENV['RM_ADHOC_PROFILE']
      app.codesign_certificate = ENV['RM_ADHOC_CERTIFICATE']
      app.info_plist['IsAdHocRelease'] = true
    end

    app.info_plist['UIFileSharingEnabled'] = true
    # fon on-device Tests (this enables iTunes File sharing so Story-Bundles can be copied to the device via iTunes)
    app.info_plist['Fabric'] = {
        'APIKey' => ENV['RM_FABRIC_API'] || 'please-set-RM_FABRIC_API-environment',
        'Kits'   => [{'KitName' => 'Crashlytics'}]
    }
  end
  # generic configuration

  app.name = 'Babbo-Voco'
  app.identifier = 'de.tuluh-tec.babbo-voco'
  app.short_version = app.version = '1.0.138'

  app.device_family = [:iphone, :ipad]
  app.interface_orientations = [:landscape_left, :landscape_right]

  app.sdk_version = '9.2'
  app.deployment_target = '8.0'
  app.icons = ['AppIcon']

  app.manifest_assets << {:kind => 'software-package', :url => '__URL__'}

  app.vendor_project('vendor/babbo-voco/js-bridging', :static, :cflags => '-fobjc-arc -F JavaScriptCore')
  app.vendor_project('vendor/babbo-voco/digest'     , :static, :cflags => '-fobjc-arc')

  app.frameworks << 'JavaScriptCore'
  app.frameworks << 'SpriteKit'
  app.frameworks << 'CoreImage'
  app.frameworks << 'AVFoundation'
end

YARD::Rake::YardocTask.new # include YARD rake task

namespace :prep do
  desc "Create symbolic links to [bundle_path] inside the CoreSimulator environment(s)"
  task :link_bundles, [:bundles_path] do |t, args|

    app = Motion::Project::App
    app.fail('usage: rake prep:link_bundles[/absolute/path/to/your/bundles/folder]') if args[:bundles_path].nil?
    app.fail('usage: rake prep:link_bundles [/absolute/path/to/your/bundles/folder]') unless args[:bundles_path].start_with? '/'
    app.fail("'#{args[:bundles_path]}' is not a valid directory!") unless File.directory? args[:bundles_path]

    Dir.glob("#{ENV['HOME']}/Library/Developer/CoreSimulator/**/Documents/Bundles").each do |link_path|
      log_path = link_path.gsub(ENV['HOME'], '~')

      if File.symlink? link_path
        app.info('Symlink', "removing old link '#{log_path}'")
        File.unlink(link_path)
      else
        new_path = "#{link_path}.%03d" % Dir.glob("#{link_path}*").length
        app.info('Symlink', "'#{log_path}' is not a symbolic link, renaming it to '#{File.basename(new_path)}'")
        File.rename(link_path, new_path)
      end
      app.info('Symlink', "Add link to #{log_path}")
      File.symlink(args[:bundles_path], link_path)
    end
  end
end

namespace :beta do

task :fabric_send do
  app = Motion::Project::App

  ENV['BUILT_PRODUCTS_DIR'] =  File.absolute_path(app.config.versionized_build_dir(app.config.deploy_platform))
  ENV['CODE_SIGN_IDENTITY'] = 'iPhone Developer'
  ENV['CONFIGURATION'] = app.config.development? ? 'Debug' : 'Release'
  ENV['DWARF_DSYM_FILE_NAME'] = File.basename(app.config.app_bundle_dsym(app.config.deploy_platform))
  ENV['DWARF_DSYM_FOLDER_PATH'] = File.absolute_path(app.config.versionized_build_dir(app.config.deploy_platform))
  ENV['EXECUTABLE_PATH'] = File.join(app.config.bundle_filename, app.config.name)
  ENV['FRAMEWORK_SEARCH_PATHS'] = "#{ENV['BUILT_PRODUCTS_DIR']} #{File.absolute_path(File.dirname(__FILE__))}"
  ENV['IPHONEOS_DEPLOYMENT_TARGET'] = app.config.deployment_target
  ENV['INFOPLIST_PATH'] = File.join(app.config.bundle_filename, 'Info.plist')
  ENV['PLATFORM_NAME'] = app.config.deploy_platform.downcase
  ENV['PRODUCT_NAME'] = app.config.name
  ENV['SDKROOT'] = `xcrun --sdk #{app.config.deploy_platform.downcase} --show-sdk-path 2>/dev/null`.strip
  ENV['SRCROOT'] = File.absolute_path(File.dirname(__FILE__))
  ENV['TARGETED_DEVICE_FAMILY'] = app.config.device_family.map { |t| { :iphone => '1', :ipad => '2' }[t] || '' }.join(',')
  ENV['WRAPPER_NAME'] = app.config.bundle_filename
  ENV['XCODE_VERSION_ACTUAL'] = `/usr/libexec/PlistBuddy #{app.config.xcode_dir}/../Info.plist -c 'print:DTXcode'`.strip
  ENV['PROJECT_FILE_PATH'] = File.absolute_path(File.join(File.dirname(__FILE__), 'vendor', 'Pods', 'Pods.xcodeproj'))

  fabric_run = File.join(Dir.pwd, 'vendor', 'Pods', 'Fabric', 'Fabric.framework', 'run')
  crashlytics_run = File.join(Dir.pwd, 'vendor', 'Pods', 'Crashlytics', 'Crashlytics.framework', 'submit')
  upload_dsym_run = File.join(Dir.pwd, 'vendor', 'Pods', 'Crashlytics', 'Crashlytics.framework', 'uploadDSYM')

  fabric_api = ENV['RM_FABRIC_API']
  fabric_key = ENV['RM_FABRIC_KEY']

  if fabric_api.nil? or fabric_key.nil?
    app.fail('Please set the RM_FABRIC_API and RM_FABRIC_KEY environment variables to your API-Key and Build-Secret.')
  end

  app.info('fabric.io', 'Submitting to fabric..')
  system("#{fabric_run} #{fabric_api} #{fabric_key}")

  app.info('fabric.io', 'Uploading dSYM..')
  system("#{upload_dsym_run} #{fabric_api} #{fabric_key}")

  app.info('fabric.io', 'Uploading to Beta..')
  system("#{crashlytics_run} #{fabric_api} #{fabric_key} -ipaPath #{app.config.archive()} -notifications YES -debug YES")
end

task :deploy => 'archive:distribution'
task :fabric_send => 'archive:distribution'
task :fabric => 'beta:fabric_send'
end

