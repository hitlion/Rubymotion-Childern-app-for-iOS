module JavaScript
  # This class is a thin wrapper for a scene object
  # which does not yet exist. E.g. a different screen.
  # It's also used for objects with no scene representation
  # like the stories 'body'.
  class FutureProxy
    include JavaScript::BridgeMixin

    javascript_export :b_b_v_j_s_bridged_future

    # Setup a new {FutureProxy} mimiking the object at +path+
    def initialize( path )
      @path = path
    end

    # Return the objects name
    def name
      @path
    end

    # Return the objects path (== it's name)
    def path
      @path
    end

    # Trigger +slot+ on the receiver.
    #
    # @param [String] slot The slot name to call.
    def emit( slot )
      JavaScript::Runtime.call_slot(@path, slot)
    end
  end
end

