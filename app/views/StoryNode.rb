class StoryNode < SKSpriteNode

  attr_accessor :center, :bundle

  def self.create_with_bundle(bundle, size: size)

    return nil unless bundle

    StoryNode.alloc.initWithColor(rmq.color.clear, size: size).tap do |node|
      node.center = false
      node.bundle = bundle
      node.anchorPoint = CGPointMake(0.5, 0.98)
      node.size = size
      node.name = bundle.productIdentifier
      node.zPosition = 5
      node.physicsBody = SKPhysicsBody.bodyWithRectangleOfSize(node.size)
      node.physicsBody.dynamic = true
      node.physicsBody.angularDamping = 5.0

      frame = SKSpriteNode.spriteNodeWithImageNamed('kids_menu/frame.png')
      frame.zPosition = -2
      frame.size = node.size
      frame.anchorPoint = CGPointMake(0.5, 1)
      node.addChild frame

      label = SKLabelNode.labelNodeWithFontNamed(TTUtil.get_font_standard(:regular))
      label.fontSize = TTUtil.get_font_size(:small)
      label.fontColor = rmq.color.black
      label.text = bundle.set_name
      label.zPosition = -1
      label.position = CGPointMake(0, - 0.35 * node.size.height)
      node.addChild label

      clip = SKSpriteNode.spriteNodeWithImageNamed('kids_menu/clip.png')
      clip.zPosition = -1
      clip.position = CGPointMake(0, 0.05 * node.size.height)
      clip.size = CGSizeMake(0.05 * node.size.height, 0.15 * node.size.height)
      clip.anchorPoint = CGPointMake(0.5, 0.5)
      node.addChild clip

      picture = SKSpriteNode.spriteNodeWithColor(rmq.color.blue, size: CGSizeMake(0.7 * node.size.width, 0.525 * node.size.width))
      picture.texture = SKTexture.textureWithImage(bundle.thumbnail)
      picture.zPosition = -3
      picture.anchorPoint = CGPointMake(0.5, 1)
      picture.position = CGPointMake(0, - 0.375 * node.size.height)
      node.addChild(picture)
    end
  end



end