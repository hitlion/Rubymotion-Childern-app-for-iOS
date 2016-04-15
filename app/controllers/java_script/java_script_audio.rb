module JavaScript
  # A wrapper around an instance of {Scene::AudioNode}.
  class AudioProxy
    include JavaScript::BridgeMixin
    include JavaScript::Common

    javascript_export :b_b_v_j_s_bridged_object
    javascript_export :b_b_v_j_s_bridged_object_audio

    # Setup a new +AudioProxy+ with a weak reference to +node+
    # 
    # @param [Scene::AudioNode] node The audio node to wrap.
    def initialize( node )
      @node = WeakRef.new(node)
    end

    ## everything below is bridged to JavaScript

    # @private
    def status
      return unless node.weakref_alive?
      node.status
    end

    # @private
    def start
      return unless node.weakref_alive?
      node.play
      JavaScript::Runtime.send_event(node.name, :at_start)
    end

    # @private
    def stop
      return unless node.weakref_alive?
      node.stop
    end

    # @private
    def pause
      return unless node.weakref_alive?
      node.pause
    end

    # @private
    def restart
      return unless node.weakref_alive?
      node.restart
    end
  end
end

