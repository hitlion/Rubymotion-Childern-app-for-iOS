module Babbo
  module JSBridge
    class Video < Babbo::JSBridge::Generic
      def start()
        PM::logger.info( "JSBridge::Video#start(#{@node.path})" )
        return unless @node.scene_node.is_a? SKVideoNode
        return unless @node.scene_node.userData[:player].is_a? AVPlayer

        @node.scene_node.userData[:player].seekToTime( KCMTimeZero )
        @node.scene_node.userData[:state] = 'play'
        @node.scene_node.play()
      end

      def stop()
        PM::logger.info( "JSBridge::Video#stop(#{@node.path})" )
        return unless @node.scene_node.is_a? SKVideoNode
        return unless @node.scene_node.userData[:player].is_a? AVPlayer

        @node.scene_node.pause()
        @node.scene_node.userData[:player].seekToTime( KCMTimeZero )
        @node.scene_node.userData[:state] = 'stop'
      end

      def pause()
        PM::logger.info( "JSBridge::Video#pause(#{@node.path})" )
        return if @node.nil?
        return unless @node.scene_node.is_a? SKVideoNode
        return unless @node.scene_node.userData[:player].is_a? AVPlayer

        @node.scene_node.pause()
        @node.scene_node.userData[:state] = 'pause'
      end

      def restart()
        PM::logger.info( "JSBridge::Video#restart(#{@node.path})" )
        return unless @node.scene_node.is_a? SKVideoNode
        return unless @node.scene_node.userData[:player].is_a? AVPlayer

        @node.scene_node.userData[:state] = 'play'
        @node.scene_node.play()
      end

      def status()
        @node.scene_node.userData[:state] || 'pause'
      end
    end
  end
end

