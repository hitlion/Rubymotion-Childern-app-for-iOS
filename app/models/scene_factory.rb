# Factory module used to convert a +Story::Screen+ and
# it's child objects to the native graphics engine objects.
#
# In case of iOS this will create a matching SpriteKit scene
# and populate it with SKNode childs for each object.
module SceneFactory
  module_function

  # Convert a screen inside a valid +StoryBundle+ into
  # a presentable scene.
  #
  # @param [StoryBundle] bundle A valid +StoryBundle+.
  # @param [String] path The path to the screen to be converted.
  # @return [SKScene] A +SKScene+ containing the screens SpriteKit version
  #   or +nil+ if +path+ is invalid or not a +Story::Screen+.
  def create_scene( bundle, path )
    story_screen = bundle.object_for_path(path)

    if story_screen.nil?
      mp "No screen available at path '#{path}'!"
      return nil
    end

    unless story_screen.is_a? Story::Screen
      mp "'#{path}' is not a Story::Screen!"
      return nil
    end
    convert_screen(bundle, story_screen)
  end

  # @private

  # Convert a single +Story::Screen+ into it's equivalent
  # +SKScene+ and add all objects in the screen as children.
  #
  # @param [StoryBundle] bundle The containing +StoryBundle+.
  # @param [Story::Screen] story_screen The screen for which the
  #   +SKScene+ should be created.
  # @return [SKScene] A populated SpriteKit scene or +nil+ if an
  #   error occurs during conversion.
  def convert_screen( bundle, story_screen )
    scene = SKScene.sceneWithSize([device.scaled_width, device.scaled_height])
    scene.name = story_screen.path

    story_screen.objects.each do |story_object|
      object = convert_object(bundle, story_object)
      if object.nil?
        mp "Scene conversion failed for '#{story_screen.path}'.",
           force_color: :red

        return nil
      else
        scene.addChild(object)
      end
    end
    scene
  end

  # Convert a +Story::Object+ inte it's equivalent
  # +SKNode+ subclass. This method will actually return
  # a class derived from one of the specialized +SKNode+'b
  # but which is API compatible with the resto of SpriteKit.
  #
  # @param [StoryBundle] bundle The containing +StoryBundle+.
  # @param [Story::Object] story_object The object to convert.
  # @return [SKNode] A specialized +SKNode+ subclass matching +story_object+
  #   or +nil+ if no conversion is available for this object type.
  def convert_object( bundle, story_object )
    mp "Converting #{story_object.type} at #{story_object.path}"
    case story_object.type
    when :picture
      Scene::PictureNode.new(bundle, story_object)
    when :audio
      Scene::AudioNode.new(bundle, story_object)
    when :video
      Scene::VideoNode.new(bundle, story_object)
    else
      mp "Object conversion failed for '#{story_object.path}'",
         force_color: :red
      mp ".. unknown :type '#{story_object.type}",
         force_color: :red
      return nil
    end
  end

  private_module_function :convert_screen
  private_module_function :convert_object
end