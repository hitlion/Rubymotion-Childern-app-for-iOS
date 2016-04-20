module Scene
  class CropNode < SKCropNode
    attr_reader :story_node

    def self.create( bundle, story_object )
      if story_object.type == :video
        @story_node = Scene::VideoNode.create(bundle, story_object)
      else
        @story_node = Scene::PictureNode.create(bundle, story_object)
      end

      lp @story_node
      z = 0

      if(story_object.mask)
        mask = SKSpriteNode.spriteNodeWithImageNamed('masks/circle-2.png')
        mask.size = @story_node.size
        mask.position = @story_node.position
        z = @story_node.zPosition
      else
        mask = nil
      end

      crop_node = CropNode.alloc.init
      crop_node.maskNode = mask
      crop_node.addChild(@story_node)
      crop_node.zPosition = z

      crop_node.name = story_object.path

      crop_node
    end
  end
end
