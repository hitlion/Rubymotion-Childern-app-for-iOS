module Babbo
  module JSBridge
    # A JavaScript proxy which *will* represent some
    class Audio < Babbo::JSBridge::Generic
      # Start the audio playback
      def start()
        with_scene_node do |scene_node|
          mp_l( "JSBridge::audio#start(#{scene_node.name})" )

          if scene_node.userData[:player].is_a? AVAudioPlayer
            scene_node.userData[:player].stop
            scene_node.userData[:player].currentTime = 0
            scene_node.userData[:player].play
            scene_node.userData[:state] = 'play'
          end
          # save to use @node since we're in this block
          @node.emit( 'at_start', scene_node.scene.document )
        end
      end

      # Stop the audio playback (and rewind to 00:00)
      def stop()
        with_scene_node do |scene_node|
          mp_l( "JSBridge::audio#stop(#{scene_node.name})" )

          if scene_node.userData[:player].is_a? AVAudioPlayer
            scene_node.userData[:player].stop
            scene_node.userData[:player].currentTime = 0
            scene_node.userData[:state] = 'stop'
          end
        end
      end

      # Like +stop+ but keep the current playback position
      def pause()
        with_scene_node do |scene_node|
          mp_l( "JSBridge::audio#pause(#{scene_node.name})" )

          if scene_node.userData[:player].is_a? AVAudioPlayer
            scene_node.userData[:player].pause
            scene_node.userData[:state] = 'pause'
          end
        end
      end

      # Restart the playback after calling +pause+
      def restart()
        with_scene_node do |scene_node|
          mp_l( "JSBridge::audio#restart(#{scene_node.name})" )

          if scene_node.userData[:player].is_a? AVAudioPlayer
            scene_node.userData[:player].play
            scene_node.userData[:state] = 'play'
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

