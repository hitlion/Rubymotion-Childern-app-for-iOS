module Scene
  class PictureNode < SKSpriteNode
    include Scene::NodeHelpersMixin

    # Create a new PictureNode bound to +story_object+
    #
    # @param [StoryBundle] bundle The {StoryBundle} containing +story_object+.
    # @param [Scene::Object] story_object The object definition.
    def initialize( bundle, story_object )
      initWithColor(rmq.color.clear, size: [0, 0]).tap do
        image = UIImage.imageWithData(bundle.asset_data(story_object.content))

        if image.nil?
          image = rmq.image.resource('placeholder/file_warning')
          lp "Missing picture for node '#{story_object.path}'",
             force_color: :yellow
        end

        self.texture  = SKTexture.textureWithImage(image)
        self.size     = calculate_node_size(story_object.size,
                                            image.size.width / image.size.height,
                                            story_object.resize)
        self.position = calculate_node_position(story_object.position,
                                                self.size)
        self.zPosition = story_object.layer
        self.alpha     = 1.0001 - story_object.transparency
        self.name      = story_object.path
      end
    end

    # @private
    def to_s
      format('<PictureNode \'%s\' position=<x=%.2f, y=%.2f, z=%.2f>, size=<w=%.2f, h=%.2f>>',
             self.name, self.position.x, self.position.y, self.zPosition,
             self.size.width, self.size.height)
    end
  end
end

