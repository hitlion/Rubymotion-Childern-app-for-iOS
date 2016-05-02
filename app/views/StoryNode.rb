class StoryNode < SKSpriteNode

  attr_accessor :center, :bundle

  def self.create_with_bundle(bundle, size: size)
    StoryNode.alloc.initWithColor(rmq.color.red, size: size).tap do |node|
      node.center = false
      node.bundle = bundle
      node.size = size
      node.position = CGPointMake(0.5 * device.screen_width, 0.5 * device.screen_height)
      node.name = "Test"

      frame = SKSpriteNode.spriteNodeWithImageNamed('kids_menu/frame.png')
      frame.zPosition = 2
      frame.size = node.size
      node.addChild frame

      label = SKLabelNode.labelNodeWithFontNamed(TTUtil.get_font_standard(:regular))
      label.fontSize = TTUtil.get_font_size(:medium)
      label.fontColor = rmq.color.black
      label.text = "No Name"
      label.zPosition = 3
      label.position = CGPointMake(0, 0.125 * node.size.height)
      node.addChild label

      clip = SKSpriteNode.spriteNodeWithImageNamed('kids_menu/clip.png')
      clip.zPosition = 3
      clip.position = CGPointMake(0, 0.525 * node.size.height)
      clip.size = CGSizeMake(0.05 * node.size.height, 0.15 * node.size.height)
      node.addChild clip

      picture = SKSpriteNode.spriteNodeWithColor(rmq.color.blue, size: CGSizeMake(0.7 * node.size.width, 0.525 * node.size.width))
      picture.zPosition = 1
      picture.position = CGPointMake(0, - 0.13 * node.size.height)
      node.addChild(picture)
    end
  end



end