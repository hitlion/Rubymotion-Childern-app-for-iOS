module JavaScript
  # A wrapper around an instance of {Scene::VideoNode}.
  class VideoProxy
    include JavaScript::BridgeMixin
    include JavaScript::Common

    javascript_export :b_b_v_j_s_bridged_object
    javascript_export :b_b_v_j_s_bridged_object_video

    # Setup a new +VideoProxy+ with a weak reference to +node+
    # 
    # @param [Scene::VideoNode] node The video node to wrap.
    def initialize( node )
      @node = WeakRef.new(node)
    end

    ##  everything below is bridged to JavaScript

    # @private
    def status
      return 'pause' if node.av_player.rate == 0.0 && node.av_player.currentTime != KCMTimeZero
      return 'play'  if node.av_player.rate >  0.0 && node.av_player.currentTime != KCMTimeZero
      'stop'
    end

    # @private
    def start
      node.av_player.seekToTime(KCMTimeZero)
      node.play

      JavaScript::Runtime.send_event(node.name, :at_start)
    end

    # @private
    def stop
      node.av_player.seekToTime(KCMTimeZero)
      node.av_player.pause
    end

    # @private
    def pause
      node.pause
    end

    # @private
    def restart
      node.play
    end
  end
end

