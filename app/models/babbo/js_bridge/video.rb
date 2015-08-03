module Babbo
  module JSBridge
    # A JavaScript proxy managing a SKVideoNode
    class Video < Babbo::JSBridge::Generic
      # Start the video playback
      def start()
        with_scene_node do |scene_node|
          mp_l( "JSBridge::Video#start(#{scene_node.name})" )
          if scene_node.is_a? SKVideoNode and scene_node.userData[:player].is_a? AVPlayer
            scene_node.userData[:player].seekToTime( KCMTimeZero )
            scene_node.userData[:state] = 'play'
            scene_node.play()
            @node.emit( 'at_start', scene_node.scene.document )
          end
        end
      end

      # Stop the video playback (and rewind to 00:00)
      def stop()
        with_scene_node do |scene_node|
          mp_l( "JSBridge::Video#stop(#{scene_node.name})" )
          if scene_node.is_a? SKVideoNode and scene_node.userData[:player].is_a? AVPlayer
            scene_node.pause()
            scene_node.userData[:player].seekToTime( KCMTimeZero )
            scene_node.userData[:state] = 'stop'
          end
        end
      end

      # Like +stop+ but keep the current playback position
      def pause()
        with_scene_node do |scene_node|
          mp_l( "JSBridge::Video#pause(#{scene_node.name})" )
          if scene_node.is_a? SKVideoNode and scene_node.userData[:player].is_a? AVPlayer
            scene_node.pause()
            scene_node.userData[:state] = 'pause'
          end
        end
      end

      # Restart the playback after calling +pause+
      def restart()
        with_scene_node do |scene_node|
          mp_l( "JSBridge::Video#restart(#{@node.path})" )
          if scene_node.is_a? SKVideoNode and scene_node.userData[:player].is_a? AVPlayer
            scene_node.userData[:state] = 'play'
            scene_node.play()
          end
        end
      end

      # Query the current playback status.
      # @return [String] 'play', 'pause', 'stop'
      def status()
        with_scene_node { |scene_node| scene_node.userData[:state] || 'pause' } || 'undef'
      end
    end
  end
end

