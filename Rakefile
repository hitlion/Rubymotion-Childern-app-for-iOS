# -*- coding: utf-8 -*-
 $:.unshift('/Library/RubyMotion/lib')
 $:.unshift( File.join( Dir.pwd, 'vendor', 'babbo-voco', 'type-monkey', 'lib' ) )

require 'motion/project/template/ios'
require 'motion-type-monkey'

require 'redcarpet'

# # in case we get un-catchable exceptions and warnings about compact unwind again
# # uncomment the following (see: http://stackoverflow.com/a/30733047/128661)
# class Motion::Project::IOSConfig
#   rm_ldflags = instance_method( :ldflags )
#   define_method( :ldflags ) do |platform|
#     rm_ldflags.bind( self ).( platform ) + ' -Wl,-keep_dwarf_unwind -Wl,-no_compact_unwind'
#   end
# end

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

    app.pods do
      pod 'HockeyKit'
      pod 'IQAudioRecorderController'
    end
  end

  app.release do
    if ENV['staging'] == 'true'
      Motion::Project::App.info('Setup', 'Configuring ad-hoc release build')

      app.provisioning_profile = ENV['RM_ADHOC_PROFILE']
      app.codesign_certificate = ENV['RM_ADHOC_CERTIFICATE']
      app.info_plist['UIFileSharingEnabled'] = true

      app.pods do
        pod 'IQAudioRecorderController'
        pod 'HockeyKit'
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
  app.short_version = app.version = '1.0.112'

  app.device_family = [ :iphone, :ipad ]

  app.sdk_version = '8.4'
  app.deployment_target = '7.1'
  app.icons = %w(Icon-58.png Icon-80.png Icon-87.png Icon-120.png Icon@2x.png Icon@3x.png)

  app.manifest_assets << { :kind => 'sotfware-package', :url => '__URL__' }

  app.vendor_project( 'vendor/babbo-voco/js-bridging', :static, :cflags => '-fobjc-arc -F JavaScriptCore' )
  app.frameworks << 'JavaScriptCore'
  app.frameworks << 'SpriteKit'
  app.frameworks << 'CoreImage'
  app.frameworks << 'AVFoundation'
end

YARD::Rake::YardocTask.new # include YARD rake task

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
      Motion::Project::App.info( 'Create', 'Creating release.html' )
      markdown = Redcarpet::Markdown.new( Redcarpet::Render::XHTML,
                                          autolink: true,
                                          tables: true,
                                          underline: true,
                                          strikethrough: true,
                                          no_intra_emphasis: true,
                                          fenced_code_blocks: true  )

      open( "#{tmpdir}/release.html", 'w' ) { |io| io.write( markdown.render( notes ) ) }

      Motion::Project::App.info( 'Create', 'Creating application.plist' )
      open( "#{tmpdir}/application.plist", 'w' ) { |io| io.write( Motion::Project::App.config.manifest_plist_data ) }

      Motion::Project::App.info( 'Copy', "Copying assets to #{deploy_server}:#{deploy_path}.." )
      release = [ 
        Motion::Project::App.config.archive(),
        "#{tmpdir}/application.plist",
        "#{tmpdir}/release.html"
      ]

      `scp #{release.join( ' ' )} #{deploy_server}:#{deploy_path}/`
    end
  end
end

task :deploy => 'archive:distribution'

