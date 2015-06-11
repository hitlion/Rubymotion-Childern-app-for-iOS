module Babbo
  module SpriteBridge
    class ObjectProxy < Proxy
      def initialize( babbo_object )
        @object = babbo_object
      end

      def create_sknode( scene )
        @node ||= begin
          content = scene.document.bundled_resource( @object.content, of_type: @object.type )
          if content == nil
            PM::logger.error("bundled_resource failed to return a valid node.")
          end

          case @object.type
            when :audio
              texture = SKTexture.textureWithImageNamed( "audioIcon.png" )
              node    = SKSpriteNode.spriteNodeWithTexture( texture )
              node.userData = { :player => content, :state => 'stop' }
              node.hidden = true

              content.delegate = scene
              content.babbo_object_id = @object.path

            when :video
              content.currentItem.babbo_object_id = @object.path
              content.actionAtItemEnd = AVPlayerActionAtItemEndPause

              node = SKVideoNode.videoNodeWithAVPlayer( content )
              node.userData = { :player => content, :state => 'stop' }

              # Setup hooks for video done callback
              notify = NSNotificationCenter.defaultCenter
              notify.removeObserver( scene,
                                      name: AVPlayerItemDidPlayToEndTimeNotification,
                                    object: content.currentItem )

              notify.addObserver( scene,
                               selector: 'on_video_done:',
                                   name: AVPlayerItemDidPlayToEndTimeNotification,
                                 object: content.currentItem )

           when :picture
              texture = SKTexture.textureWithImage( content )
              node    = SKSpriteNode.spriteNodeWithTexture( texture )
          end

          node.alpha = 1.0 - @object.alpha # JSON has this as "transparency 0.0..1.0"
          node.zPosition = @object.layer.to_f
          node.position = calc_position( @object.position, @object.size )
          node.size = calc_size( UIScreen.mainScreen.bounds.size, @object.size )
          node.name = @object.path

          node.userInteractionEnabled = true

          PM::logger.info( "node { '#{node.name}', zPos: #{node.zPosition}, pos: [#{node.position.x}, #{node.position.y}], size: [#{node.size.width}, #{node.size.height}], alpha: #{node.alpha} }" )
          node
        end

        @object.scene_node = node
        @node
      end
    end
  end
end

