module Babbo
  module SpriteBridge
    class ObjectProxy < Proxy
      def initialize( babbo_object )
        @object = babbo_object
      end

      def create_sknode( scene, enable_editor = false )
        content = scene.document.bundled_resource( @object.content, of_type: @object.type )
        if content == nil
          mp_e("bundled_resource failed to return a valid node.")
        end

        case @object.type
          when :audio
            texture = SKTexture.textureWithImageNamed( "file_music.png" )
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
            if content.is_a? NSData
              node = SKSpriteNode.spriteNodeFromAnimatedGif( content )
            else
              texture = SKTexture.textureWithImage( content )
              node    = SKSpriteNode.spriteNodeWithTexture( texture )
            end
        end

        node.name = @object.path
        node.position = calc_position( @object.position, @object.size )
        node.size = calc_size( UIScreen.mainScreen.bounds.size, @object.size )

        if enable_editor
          if @object.modifiable
            node.alpha     = 1.0
            node.zPosition = 9988.0
            node.hidden    = false
            case @object.type
              when :audio
                node.size = [ 128, 128 ]
            end

          else
            node.alpha     = 0.25
            node.zPosition = @object.layer.to_f
          end
        else
          case @object.type
            when :audio
              node.size      = [ 1, 1 ]
              node.position  = [ 0, 0 ]
              node.hidden    = true
              node.zPosition = 0.0
              node.userInteractionEnabled = false

            when :picture, :video
              # Note: iOS9 requires a node to have alpha > 0.0 to be able to receive touches!
              node.alpha     = 1.001 - @object.alpha # JSON has this as "transparency 0.0..1.0"
              node.zPosition = @object.layer.to_f
              node.userInteractionEnabled = true
          end
        end

        mp_d( "node { '#{node.name}', zPos: #{node.zPosition}, pos: [#{node.position.x}, #{node.position.y}], size: [#{node.size.width}, #{node.size.height}], alpha: #{node.alpha} }" )
        node
      end
    end
  end
end

