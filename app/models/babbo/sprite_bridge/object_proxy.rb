class SpriteNode < SKSpriteNode
  def dealloc
    NSLog("Deallocating <#{self} / #{self.name}>")
    super
  end
end

class VideoNode < SKVideoNode
  def dealloc
    NSLog("Deallocating video <#{self} / #{self.name}>")
    super
  end
end

class BVPlayer < AVPlayer
  def dealloc
    NSLog("Deallocating <#{self} / #{self.name}>")
    super
  end
end

module Babbo
  module SpriteBridge
    class ObjectProxy < Proxy
      def initialize( babbo_object )
        @object = babbo_object
      end

      def create_sknode( scene )
        content = scene.document.bundled_resource( @object.content, of_type: @object.type )
        if content == nil
          mp_e("bundled_resource failed to return a valid node.")
        end

        case @object.type
          when :audio
            texture = SKTexture.textureWithImageNamed( "file_music.png" )
            #node    = SKSpriteNode.spriteNodeWithTexture( texture )
            node    = SpriteNode.alloc.initWithTexture( texture )
            node.userData = { :player => content, :state => 'stop' }
            node.hidden = true

            content.delegate = scene
            content.babbo_object_id = @object.path

          when :video
            content.currentItem.babbo_object_id = @object.path
            content.actionAtItemEnd = AVPlayerActionAtItemEndPause

            node = VideoNode.alloc.initWithAVPlayer( content )
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
              #node = SKSpriteNode.spriteNodeFromAnimatedGif( content )
              node = SpriteNode.spriteNodeFromAnimatedGif( content )
            else
              texture = SKTexture.textureWithImage( content )
              #node    = SKSpriteNode.spriteNodeWithTexture( texture )
              node    = SpriteNode.spriteNodeWithTexture( texture )
            end
        end

        node.alpha = 1.0 - @object.alpha # JSON has this as "transparency 0.0..1.0"
        node.zPosition = @object.layer.to_f
        node.position = calc_position( @object.position, @object.size )
        node.size = calc_size( UIScreen.mainScreen.bounds.size, @object.size )
        node.name = @object.path

        node.userInteractionEnabled = true

        mp_l( "node { '#{node.name}', zPos: #{node.zPosition}, pos: [#{node.position.x}, #{node.position.y}], size: [#{node.size.width}, #{node.size.height}], alpha: #{node.alpha} }" )
        node
      end
    end
  end
end

