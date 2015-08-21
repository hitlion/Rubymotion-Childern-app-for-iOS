module JavaScript
  # RubyMotion has no native support for Objective-C Protocols but they
  # are required for propper export control to JavaScriptCore contexts.
  #
  # This module uses the Objective-C class +BBVJSBridgingHelper+ to inject
  # arbitrary protocols into native Ruby-classes at runtime.
  module BridgeMixin
    module ClassMixin
      # Declare that this class supports certain JSExport based protocols.
      # Protocol names are specified as +Symbols+ with the following
      # transformations applied:
      #
      # - underscores will be stripped
      # - the first letter will be capitalized
      # - each first letter after an underscore will be capitalized
      #
      # @param [Array<Symbol>] names The list of JSExport protocols this class
      #   implements.
      def javascript_export( *names )
        names.each do |name|
          name = name.to_s.split(/_/).map{ |n| n.capitalize }.join('')
          # see vendor/babbo-voco/js-bridging for details
          BBVJSBridgingHelper.injectProtocol(name, intoClass: self)
        end
      end
    end

    def self.included( base )
      base.extend(JavaScript::BridgeMixin::ClassMixin)
    end
  end
end

