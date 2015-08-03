# -*- coding: utf-8 -*-
 $:.unshift('/Library/RubyMotion/lib')
 $:.unshift( File.join( Dir.pwd, 'vendor', 'babbo-voco', 'type-monkey', 'lib' ) )

require 'motion/project/template/ios'
require 'motion-type-monkey'

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
begin
  require 'bundler'
  Bundler.setup
  Bundler.require
rescue LoadError
  App.warn 'Failed to require \'bundler\'!'
end

task 'crescentia:run' => 'build:simulator'

# Sources only included in development and test builds.
DEVELOPMENT_ONLY = Dir.glob( "#{Dir.pwd}/app/**/*+devel.rb" )

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.development do
    if ENV['staging'] == 'true'
      Motion::Project::App.info('Setup', 'Configuring ad-hoc development build')

      app.provisioning_profile = ENV['RM_ADHOC_PROFILE']
      app.codesign_certificate = ENV['RM_ADHOC_CERTIFICATE']
   else
      app.provisioning_profile = ENV['RM_DEV_PROFILE']
      app.codesign_certificate = ENV['RM_DEV_CERTIFICATE']
    end
    # for Spec tests
    app.info_plist['SPEC_HOST_PATH'] = File.absolute_path( Dir.pwd )
    # fon on-device Tests (this enables iTunes File sharing so Story-Bundles can be copied to the device via iTunes)
    app.info_plist['UIFileSharingEnabled'] = true
    app.info_plist['Fabric'] = {
        'APIKey' => ENV['RM_FABRIC_API'] || 'please-set-RM_FABRIC_API-environment',
        'Kits'   => [
          { 'KitName' => 'Crashlytics' }
        ]
    }

    app.pods do
      pod 'HockeyKit'
      pod 'IQAudioRecorderController'
      pod 'Fabric'
      pod 'Crashlytics'
    end
  end

  app.release do
    if ENV['staging'] == 'true'
      Motion::Project::App.info('Setup', 'Configuring ad-hoc release build')

      app.provisioning_profile = ENV['RM_ADHOC_PROFILE']
      app.codesign_certificate = ENV['RM_ADHOC_CERTIFICATE']
      app.info_plist['UIFileSharingEnabled'] = true
      app.info_plist['Fabric'] = {
        'APIKey' => ENV['RM_FABRIC_API'] || 'please-set-RM_FABRIC_API-environment',
        'Kits'   => [
          { 'KitName' => 'Crashlytics' }
        ]
      }

      app.pods do
        pod 'IQAudioRecorderController'
        pod 'HockeyKit'
        pod 'Fabric'
        pod 'Crashlytics'
      end
    else 
      app.provisioning_profile = ENV['RM_PUB_PROFILE']
      app.codesign_certificate = ENV['RM_PUB_CERTIFICATE']

      app.pods do
        pod 'IQAudioRecorderController'
      end
    end
    # Filter out development helpers
    app.files.select! { |x| true unless DEVELOPMENT_ONLY.include? x }
  end

  app.name = 'Babbo-Voco'
  app.identifier = 'de.tuluh-tec.babbo-voco'
  app.short_version = app.version = '1.0.119'

  app.device_family = [ :iphone, :ipad ]

  app.sdk_version = '8.4'
  app.deployment_target = '7.1'
  app.icons = %w(Icon-58.png Icon-80.png Icon-87.png Icon-120.png Icon@2x.png Icon@3x.png)

  app.manifest_assets << { :kind => 'software-package', :url => '__URL__' }

  app.vendor_project( 'vendor/babbo-voco/js-bridging', :static, :cflags => '-fobjc-arc -F JavaScriptCore' )
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
    Motion::Project::App.fail( 'Please set the RM_HOCKEY_SERVER and RM_HOCKEY_PATH environment variables!' )
  end

  if editor.nil?
    # we need to provide some release-notes after all..
    Motion::Project::App.fail( 'Please set the EDITOR environment variable!' )
  end

  Motion::Project::App.info( 'Deploy', 'Preparing release notes template..' )
  Dir.mktmpdir( 'deploy', nil ) do |tmpdir|
    tagline ='~~ write your release notes above and then delete this line, markdown syntax is expected ~~'

    open( "#{tmpdir}/release.md", 'w' ) do |io|
      io.write( tagline )
    end

    `#{editor} #{tmpdir}/release.md`
    notes = File.read( "#{tmpdir}/release.md" )

    if notes[/#{tagline}/]
      Motion::Project::App.warn( 'No changes to the release notes detected, aborting.' )
    else
      app = Motion::Project::App

      app.info( 'Create', 'Creating release.html' )
      markdown = Redcarpet::Markdown.new( Redcarpet::Render::XHTML,
                                          autolink: true,
                                          tables: true,
                                          underline: true,
                                          strikethrough: true,
                                          no_intra_emphasis: true,
                                          fenced_code_blocks: true  )

      open( "#{tmpdir}/release.html", 'w' ) { |io| io.write( markdown.render( notes ) ) }

      app.info( 'Create', 'Creating application.plist' )
      open( "#{tmpdir}/application.plist", 'w' ) do |io|
        io.write( File.read( File.join( app.config.versionized_build_dir( app.config.deploy_platform ), 'manifest.plist' ) ) )
      end

      app.info( 'Copy', "Copying assets to #{deploy_server}:#{deploy_path}.." )
      release = [ 
        app.config.archive(),
        "#{tmpdir}/application.plist",
        "#{tmpdir}/release.html"
      ]

      `scp #{ENV['RM_SCP_OPTIONS'] || ''} #{release.join( ' ' )} #{deploy_server}:#{deploy_path}/`
    end
  end
end

task :fabric_send do
  app = Motion::Project::App

  ENV['BUILT_PRODUCTS_DIR'] =  app.config.versionized_build_dir( app.config.deploy_platform )
  ENV['INFOPLIST_PATH'] = File.join( app.config.bundle_filename, 'Info.plist' )
  ENV['DWARF_DSYM_FILE_NAME'] = File.basename( app.config.app_bundle_dsym( app.config.deploy_platform ) )
  ENV['DWARF_DSYM_FOLDER_PATH'] = app.config.versionized_build_dir( app.config.deploy_platform )
  ENV['SRCROOT'] = File.dirname( __FILE__ )

  fabric_run = File.join( Dir.pwd, 'vendor', 'Pods', 'Fabric', 'Fabric.framework', 'run' )
  fabric_api = ENV['RM_FABRIC_API']
  fabric_key = ENV['RM_FABRIC_KEY']

  if fabric_api.nil? or fabric_key.nil?
    app.fail( 'Please set the RM_FABRIC_API and RM_FABRIC_KEY environment variables to your API-Key and Build-Secret.' )
  end

  system( "#{fabric_run} #{fabric_api} #{fabric_key}" )
end

task :deploy => 'archive:distribution'
task :fabric => ['beta:deploy', 'beta:fabric_send']

end

