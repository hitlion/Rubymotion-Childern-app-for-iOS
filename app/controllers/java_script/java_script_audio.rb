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
      node.status
    end

    # @private
    def start
      node.play
      JavaScript::Runtime.send_event(node.name, :at_start)
    end

    # @private
    def stop
      node.stop
    end

    # @private
    def pause
      node.pause
    end

    # @private
    def restart
      node.restart
    end
  end
end

