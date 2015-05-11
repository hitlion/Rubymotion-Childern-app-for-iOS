module Babbo
  module JSBridge
    def inject_protocols()
      # RubyMotion has no native support for Objective-C Protocols
      # In our case this as bad since JavaScriptCore uses a hack on the JSExport-Protocol to do
      # it's magic.
      #
      # BBVJSBridgingHelper is a Objective-C class which uses the low-level C-API to lookup
      # and then inject a named Protocol into a class at runtime.
      # The result with regard to JavaScriptCore is no different than if the classes where declared
      # with the Protocol in the first place.

      BBVJSBridgingHelper.injectProtocol( 'BBVJSBridgedObject', intoClass: Babbo::JSBridge::Video )
      BBVJSBridgingHelper.injectProtocol( 'BBVJSBridgedObjectVideo', intoClass: Babbo::JSBridge::Video )

      BBVJSBridgingHelper.injectProtocol( 'BBVJSBridgedObject', intoClass: Babbo::JSBridge::Audio )
      BBVJSBridgingHelper.injectProtocol( 'BBVJSBridgedObjectAudio', intoClass: Babbo::JSBridge::Audio )

      BBVJSBridgingHelper.injectProtocol( 'BBVJSBridgedObject', intoClass: Babbo::JSBridge::Picture )
      BBVJSBridgingHelper.injectProtocol( 'BBVJSBridgedObjectPicture', intoClass: Babbo::JSBridge::Picture )

      BBVJSBridgingHelper.injectProtocol( 'BBVJSBridgedObject', intoClass: Babbo::JSBridge::Screen )
      BBVJSBridgingHelper.injectProtocol( 'BBVJSBridgedObjectScreen', intoClass: Babbo::JSBridge::Screen )
    end

    def proxy_for_object( obj )
      if obj.is_a? Babbo::Screen
        return Babbo::JSBridge::Screen.new( obj )
      elsif obj.is_a? Babbo::Object
        case obj.type
          when :audio
            return Babbo::JSBridge::Audio.new( obj )
          when :video
            return Babbo::JSBridge::Video.new( obj )
          when :picture
            return Babbo::JSBridge::Picture.new( obj )
        end
      end
      PM::logger.error( "No known JSBridge proxy for class #{obj.class}!" )
      nil
    end

    module_function :inject_protocols
    module_function :proxy_for_object
  end
end
