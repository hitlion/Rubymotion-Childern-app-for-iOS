# -*- coding: utf-8 -*-
 $:.unshift('/Library/RubyMotion/lib')

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

    unless ENV['staging'] == true
      # also filter out ad-hoc / beta related code
      app.files.select! { |x| true unless ADHOC_BETA_ONLY.include? x }
    end
  end

  # pods used in all configurations
  app.pods do
    pod 'IQAudioRecorderController'
    pod 'zipzap'
  end

  if ENV['staging'] == 'true' or app.development?

    app.entitlements['get-task-allow'] = true
    #app.entitlements['beta-reports-active'] = true

    if ENV['staging'] == 'true'
      app.entitlements['get-task-allow'] = false
      #app.instance_eval{ @embed_dsym = true }
      app.embed_dsym = true # embedd dsyms in ad-hoc releases

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

    app.pods do
      pod 'Fabric'
      pod 'Crashlytics', '= 3.1.0'
      pod 'HockeyKit'
    end
  end
  # generic configuration

  app.name = 'Babbo-Voco'
  app.identifier = 'de.tuluh-tec.babbo-voco'
  app.short_version = app.version = '1.0.130'

  app.device_family = [:iphone, :ipad]
  app.interface_orientations = [:landscape_left, :landscape_right]

  app.sdk_version = '9.0'
  app.deployment_target = '7.1'
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

namespace :beta do

desc 'Deploy an ad-hoc build to a HockeyKit server'
task :deploy do
  deploy_server = ENV['RM_HOCKEY_SERVER']
  deploy_path   = ENV['RM_HOCKEY_PATH']
  editor        = ENV['EDITOR']

  if deploy_path.nil? or deploy_server.nil?
    Motion::Project::App.fail('Please set the RM_HOCKEY_SERVER and RM_HOCKEY_PATH environment variables!')
  end

  if editor.nil?
    # we need to provide some release-notes after all..
    Motion::Project::App.fail('Please set the EDITOR environment variable!')
  end

  Motion::Project::App.info('Deploy', 'Preparing release notes template..')
  Dir.mktmpdir('deploy', nil) do |tmpdir|
    tagline ='~~ write your release notes above and then delete this line, markdown syntax is expected ~~'

    open("#{tmpdir}/release.md", 'w') do |io|
      io.write(tagline)
    end

    system("#{editor} #{tmpdir}/release.md")
    notes = File.read("#{tmpdir}/release.md")

    if notes[/#{tagline}/]
      Motion::Project::App.warn('No changes to the release notes detected, aborting.')
    else
      app = Motion::Project::App

      app.info('Create', 'Creating release.html')
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::XHTML,
                                         autolink: true,
                                         tables: true,
                                         underline: true,
                                         strikethrough: true,
                                         no_intra_emphasis: true,
                                         fenced_code_blocks: true)

      open("#{tmpdir}/release.html", 'w') { |io| io.write(markdown.render(notes)) }

      app.info('Create', 'Creating application.plist')
      open("#{tmpdir}/application.plist", 'w') do |io|
        io.write(File.read(File.join(app.config.versionized_build_dir(app.config.deploy_platform), 'manifest.plist')))
      end

      app.info('Copy', "Copying assets to #{deploy_server}:#{deploy_path}..")
      release = [ 
        app.config.archive(),
        "#{tmpdir}/application.plist",
        "#{tmpdir}/release.html"
      ]

      system("scp #{ENV['RM_SCP_OPTIONS'] || ''} #{release.join(' ')} #{deploy_server}:#{deploy_path}/")
    end
  end
end

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

  fabric_api = ENV['RM_FABRIC_API']
  fabric_key = ENV['RM_FABRIC_KEY']

  if fabric_api.nil? or fabric_key.nil?
    app.fail('Please set the RM_FABRIC_API and RM_FABRIC_KEY environment variables to your API-Key and Build-Secret.')
  end

  system("#{fabric_run} #{fabric_api} #{fabric_key}")
  system("#{crashlytics_run} #{fabric_api} #{fabric_key} -ipaPath #{app.config.archive()} -notifications YES -debug YES")
end

task :deploy => 'archive:distribution'
task :fabric => ['beta:deploy', 'beta:fabric_send']

end
