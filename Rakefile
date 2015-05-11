# -*- coding: utf-8 -*-
 $:.unshift('/Library/RubyMotion/lib')
 $:.unshift( File.join( Dir.pwd, 'vendor', 'babbo-voco', 'type-monkey', 'lib' ) )

require 'motion/project/template/ios'
require 'motion-type-monkey'

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
    app.provisioning_profile = ENV['RM_DEV_PROFILE']
    app.codesign_certificate = ENV['RM_DEV_CERTIFICATE']
    # for Spec tests
    app.info_plist['SPEC_HOST_PATH'] = File.absolute_path( Dir.pwd )
    # fon on-device Tests (this enables iTunes File sharing so Story-Bundles can be copied to the device via iTunes)
    app.info_plist['UIFileSharingEnabled'] = true
  end

  app.release do
    app.provisioning_profile = ENV['RM_PUB_PROFILE']
    app.codesign_certificate = ENV['RM_PUB_CERTIFICATE']

    # Filter out development helpers
    app.files.select! { |x| true unless DEVELOPMENT_ONLY.include? x }
  end

  app.name = 'Babbo-Voco'
  app.identifier = 'de.tuluh-tec.babbo-voco'
  app.short_version = app.version = '1.0'

  app.sdk_version = '8.3'
  app.deployment_target = '7.1'

  app.vendor_project( 'vendor/babbo-voco/js-bridging', :static, :cflags => '-fobjc-arc -fno-exceptions -F JavaScriptCore' )
  app.frameworks << 'JavaScriptCore'
  app.frameworks << 'SpriteKit'
end

YARD::Rake::YardocTask.new # include YARD rake task

