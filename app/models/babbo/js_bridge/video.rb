module Babbo
  module JSBridge
    # A JavaScript proxy managing a SKVideoNode
    class Video < Babbo::JSBridge::Generic
      # Start the video playback
      def start()
        mp_l( "JSBridge::Video#start(#{@node.path})" )
        return unless @node.scene_node.is_a? SKVideoNode
        return unless @node.scene_node.userData[:player].is_a? AVPlayer

        @node.scene_node.userData[:player].seekToTime( KCMTimeZero )
        @node.scene_node.userData[:state] = 'play'
        @node.scene_node.play()
      end

      # Stop the video playback (and rewind to 00:00)
      def stop()
        mp_l( "JSBridge::Video#stop(#{@node.path})" )
        return unless @node.scene_node.is_a? SKVideoNode
        return unless @node.scene_node.userData[:player].is_a? AVPlayer

        @node.scene_node.pause()
        @node.scene_node.userData[:player].seekToTime( KCMTimeZero )
        @node.scene_node.userData[:state] = 'stop'
      end

      # Like +stop+ but keep the current playback position
      def pause()
        mp_l( "JSBridge::Video#pause(#{@node.path})" )
        return if @node.nil?
        return unless @node.scene_node.is_a? SKVideoNode
        return unless @node.scene_node.userData[:player].is_a? AVPlayer

        @node.scene_node.pause()
        @node.scene_node.userData[:state] = 'pause'
      end

      # Restart the playback after calling +pause+
      def restart()
        mp_l( "JSBridge::Video#restart(#{@node.path})" )
        return unless @node.scene_node.is_a? SKVideoNode
        return unless @node.scene_node.userData[:player].is_a? AVPlayer

        @node.scene_node.userData[:state] = 'play'
        @node.scene_node.play()
      end

      # Query the current playback status.
      # @return [String] 'play', 'pause', 'stop'
      def status()
        @node.scene_node.userData[:state] || 'pause'
      end
    end
  end
end

