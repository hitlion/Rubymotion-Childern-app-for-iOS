module Scene
  class TextNode < SKLabelNode
    include Scene::NodeHelpersMixin

    # Create a new TextNode bound to +story_object+
    #
    # @param [StoryBundle] bundle The {StoryBundle} containing +story_object+.
    # @param [Scene::Object] story_object The object definition.
    def self.create( bundle, story_object )

      font  = rmq.font.pad_small.fontName

      TextNode.alloc.initWithFontNamed(font).tap do |node|

        x = device.screen_width * story_object.position.x
        y = device.screen_height - device.screen_height * story_object.position.y
        node.position  = CGPointMake(x,y)
        node.zPosition = story_object.layer
        node.alpha     = 1.0001 - story_object.transparency
        node.name      = story_object.path
        node.text      = story_object.content
        node.fontSize  = 40
        node.hidden    = true
      end
    end

    # @private
    def to_s
      format('<TextNode \'%s\'  position=<x=%.2f, y=%.2f, z=%.2f>',
             self.name, self.position.x, self.position.y, self.zPosition)
    end
  end
end

