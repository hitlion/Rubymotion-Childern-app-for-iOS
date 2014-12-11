# -*- coding: utf-8 -*-
$:.unshift('/Library/RubyMotion/lib')
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.setup
  Bundler.require
rescue LoadError
  App.warn 'Failed to require \'bundler\'!'
end

task 'crescentia:run' => 'build:simulator'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.

  development_only = Dir.glob( "#{Dir.pwd}/app/**/*+devel.rb" )

  app.development do
    app.provisioning_profile = ENV['RM_DEV_PROFILE']
    app.codesign_certificate = ENV['RM_DEV_CERTIFICATE']
    # for Spec tests
    app.info_plist['SPEC_HOST_PATH'] = File.absolute_path( Dir.pwd )
  end

  app.release do
    app.provisioning_profile = ENV['RM_PUB_PROFILE']
    app.codesign_certificate = ENV['RM_PUB_CERTIFICATE']

    # Filter out development helpers
    app.files.select! { |x| true unless development_only.include? x }
  end

  app.name = 'Babbo-Voco'
  app.identifier = 'de.tuluh-tec.babbo-voco'
  app.short_version = app.version = '1.0'

  app.sdk_version = '8.1'
  app.deployment_target = '7.1'
end
