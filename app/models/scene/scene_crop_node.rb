module Scene

  class CropNode < SKCropNode
    alias :'super_runAction:' :'runAction:'

    include Scene::NodeHelpersMixin

    attr_accessor :node_object,

    def self.create( bundle, story_object )
      if story_object.type == :video
        node = Scene::VideoNode.create(bundle, story_object)
      else
        node = Scene::PictureNode.create(bundle, story_object)
      end

      crop_node = CropNode.alloc.init
      crop_node.position = node.position
      crop_node.zPosition = node.zPosition
      crop_node.name = node.name

      node.position = CGPointMake (0,0)
      node.zPosition = 0
      node.name = "CN" + node.name

      if(story_object.mask)
        texture = SKTexture.textureWithImage (UIImage.imageWithData(bundle.asset_data(story_object.mask)))
        mask = SKSpriteNode.spriteNodeWithTexture(texture)
        mask.size = node.size
        mask.position = node.position
      else
        mask = nil
      end

      crop_node.maskNode = mask
      crop_node.addChild(node)

      crop_node.node_object = node

      crop_node
    end

    def size
      if @node_object
        return @node_object.size
      else
        return CGSizeMake(0,0)
      end
    end

    def setSize(size)
      lp 'Size', force_color: :red
    end

    def size=(size)
      if @node_object
        @node_object.size = size
      end

      if(self.maskNode)
        self.maskNode.size = size
      end
    end

    def to_s
      if @node_object
        return @node_object.to_s
      else
        return ""
      end
    end

    def play
      if @node_object.is_a? Scene::VideoNode
        @node_object.play
      end
    end

    def av_player
      if @node_object.is_a? Scene::VideoNode
        return @node_object.av_player
      end
    end

    def stop
      if @node_object.is_a? Scene::VideoNode
        @node_object.stop
      end
    end

    def pause
      if @node_object.is_a? Scene::VideoNode
        @node_object.pause
      end
    end

    def texture=(texture)
      if @node_object.is_a? Scene::PictureNode
        @node_object.texture = texture
      end
    end

    def texture
      if @node_object.is_a? Scene::PictureNode
        return @node_object.texture
      end
      return nil
    end

    # must use this because set the alpha of the cropnode doesnt effect the children if there is a mask!=nil...
    def alpha=(value)
      if @node_object
        @node_object.alpha = value
      end
    end

    def alpha
      if @node_object
        return @node_object.alpha
      end
      return nil
    end

    def setAlpha(value)
      lp value
    end

  end
end
