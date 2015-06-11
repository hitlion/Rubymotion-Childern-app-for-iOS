module Babbo
  module JSBridge
    # A JavaScript proxy which *will* represent some
    # Kind of audio node (TODO)
    class Audio < Babbo::JSBridge::Generic
      # Start the audio playback
      def start()
        PM::logger.info( "JSBridge::audio#start(#{@node.path})" )
        return unless @node.scene_node.userData[:player].is_a? AVAudioPlayer

        @node.scene_node.userData[:player].stop
        @node.scene_node.userData[:player].currentTime = 0
        @node.scene_node.userData[:player].play
        @node.scene_node.userData[:state] = 'play'
      end

      # Stop the audio playback (and rewind to 00:00)
      def stop()
        PM::logger.info( "JSBridge::audio#stop(#{@node.path})" )
        return unless @node.scene_node.userData[:player].is_a? AVAudioPlayer

        @node.scene_node.userData[:player].stop
        @node.scene_node.userData[:player].currentTime = 0
        @node.scene_node.userData[:state] = 'stop'
      end

      # Like +stop+ but keep the current playback position
      def pause()
        PM::logger.info( "JSBridge::audio#pause(#{@node.path})" )
        return if @node.nil?

        return unless @node.scene_node.userData[:player].is_a? AVAudioPlayer

        @node.scene_node.userData[:player].pause
        @node.scene_node.userData[:state] = 'pause'
      end

      # Restart the playback after calling +pause+
      def restart()
        PM::logger.info( "JSBridge::audio#restart(#{@node.path})" )
        return unless @node.scene_node.is_a? SKaudioNode
        return unless @node.scene_node.userData[:player].is_a? AVAudioPlayer

        @node.scene_node.userData[:player].play
        @node.scene_node.userData[:state] = 'play'
      end

      # Query the current playback status.
      # @return [String] 'play', 'pause', 'stop'
      def status()
        @node.scene_node.userData[:state] || 'pause'
      end
    end
  end
end

