# Extend `SKSpriteNode` to support animated GIF images
class SKSpriteNode

  class << self
    def spriteNodeFromAnimatedGif(data)
      source = CGImageSourceCreateWithData(data, nil)
      node   = nil
      if source.nil?
        NSLog("Error - unable to create a CGImageSource from '#{url}'.")
      else
        count = CGImageSourceGetCount(source)
        NSLog("ImageSource contains #{count} images.")
        node = create_textures(source, count)
      end

      if node.nil?
        texture = SKTexture.textureWithImageNamed( "file_warning.png" )
        node    = SKSpriteNode.spriteNodeWithTexture( texture )
      end
      node
    end

    private

    def create_textures(source, count)
      textures = []
      delay    = 0
      ( 0...count ).each do |n|
        image = CGImageSourceCreateImageAtIndex( source, n, nil )
        delay += get_delay_from_image( source, n )

        unless image.nil?
          textures << SKTexture.textureWithCGImage( image )
        end
      end

      if count > 0
        animation = SKAction.animateWithTextures( textures, timePerFrame: delay / textures.count )
        node = SKSpriteNode.spriteNodeWithTexture( textures[0] )

        node.runAction( SKAction.repeatActionForever( animation ) )
        node
      else
        nil
      end
    end

    def get_delay_from_image(source, index)
      delay = 1
      properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)

      unless properties.nil?
        gif_props = properties[KCGImagePropertyGIFDictionary]

        unless gif_props.nil?
          t = gif_props[KCGImagePropertyGIFUnclampedDelayTime]
          if t.nil? or t.doubleValue == 0
            t = gif_props[KCGImagePropertyGIFDelayTime] || NSNumber.numberWithDouble( 1.0 )
          end

          if t.doubleValue > 0
            delay = t.doubleValue
          end
        end
      end
      delay
    end
  end
end
