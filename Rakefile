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

require 'motion-calabash-wrapper'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.

  app.development do
    app.provisioning_profile = ENV['RM_DEV_PROFILE']
    app.codesign_certificate = ENV['RM_DEV_CERTIFICATE']
  end

  app.release do
    app.provisioning_profile = ENV['RM_PUB_PROFILE']
    app.codesign_certificate = ENV['RM_PUB_CERTIFICATE']
  end

  app.name = 'Babbo-Voco'
  app.identifier = 'de.thulu-tec.babbo-voco'
  app.short_version = app.version = '1.0'

  app.sdk_version = '8.1'
  app.deployment_target = '7.1'

end
