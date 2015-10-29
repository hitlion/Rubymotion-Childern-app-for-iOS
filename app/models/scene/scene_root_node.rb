module Scene
  class RootNode < SKScene
    include Scene::NodeHelpersMixin

    attr_reader :screen_id

    # Create a new RootNode bound to +story_object+
    #
    # @param [StoryBundle] bundle The {StoryBundle} containing +story_object+.
    # @param [Scene::Object] story_object The object definition.
    def self.create( bundle, story_object )
      RootNode.alloc.initWithSize([device.screen_width, device.screen_height]).tap do |scene|
        scene.instance_eval do
          self.name  = story_object.path
          @screen_id = story_object.id
        end
      end
    end

    # @private
    def to_s
      format('<RootNode \'%s\' position=<x=%.2f, y=%.2f, z=%.2f>, size=<w=%.2f, h=%.2f>>',
             self.name, self.position.x, self.position.y, self.zPosition,
             self.size.width, self.size.height)
    end
  end
end

