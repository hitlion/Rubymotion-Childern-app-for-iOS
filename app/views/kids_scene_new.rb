class KidsSceneNew < SKScene

  def didMoveToView(view)
    super

    physicsWorld.gravity = CGVectorMake(0.0, -100.0)
    physicsWorld.contactDelegate = self

    create_scene
  end

  def touchesBegan(touches, withEvent: event)
    super

    @sum_movement = 0

    touch = touches.anyObject
    node = nodeAtPoint(touch.locationInNode(self))

    return unless node

    lp node.name

    case node.name
      when 'parent_button'
        parent_button_clicked(node)
    end
  end

  def touchesMoved(touches, withEvent: event)
    super

    touch = event.touchesForView(self.view).anyObject
    location = touch.locationInView(self.view)
    prev_location = touch.previousLocationInView(self.view)

    direction = location.x - prev_location.x

    @sum_movement += direction.abs
    lp @sum_movement

    if @sum_movement > 50
      move_rope_by_x(1.5 * direction, 0.02)
    end
  end

  def create_scene
    background = SKSpriteNode.spriteNodeWithTexture(SKTexture.textureWithImageNamed('kids_menu/background.png'))
    background.position = CGPointMake(0.5 * device.screen_width, 0.5 * device.screen_height)
    background.name = 'background'
    background.zPosition = 0
    background.size = self.view.frame.size
    addChild background

    parent_menu = SKSpriteNode.spriteNodeWithTexture(SKTexture.textureWithImageNamed('babbo_icons/parent_button.png'))
    parent_menu.name = 'parent_button'
    parent_menu.zPosition = 1
    parent_menu.position = CGPointMake(0.2 * device.screen_width, 0.80 * device.screen_height)
    parent_menu.size = CGSizeMake(0.2 * device.screen_height, 0.2 * device.screen_height)
    addChild parent_menu

    logo = SKSpriteNode.spriteNodeWithTexture(SKTexture.textureWithImageNamed('kids_menu/logo.png'))
    logo.name = 'logo'
    logo.zPosition = 1
    logo.position = CGPointMake(0.8 * device.screen_width, 0.80 * device.screen_height)
    logo.size = CGSizeMake(0.2 * device.screen_height, 0.2 * device.screen_height)
    addChild logo

    bundles = StoryBundle.bundles.select { |b| b.valid? }

    @story_nodes = []

    bundles.each_with_index do |bundle, index|
      node = StoryNode.create_with_bundle(bundle, size: CGSizeMake(0.25 * device.screen_height, 0.25 * device.screen_height))
      node.position = CGPointMake(0.5 * device.screen_width + index * 0.4 * device.screen_width, 0.55 * device.screen_height)
      @story_nodes << node
      addChild node
    end

    @story_nodes.first.center = true

    rope_width = 2 * device.screen_width + @story_nodes.length * 0.4 * device.screen_width
    rope = SKSpriteNode.spriteNodeWithColor(rmq.color.clear, size: CGSizeMake(rope_width, device.screen_height / 50))
    rope.name = 'rope'
    rope.position = CGPointMake(- 0.5 * device.screen_width, 0.55 * device.screen_height)
    rope.anchorPoint = CGPointMake(0.0, 0.5)
    rope.zPosition = 3
    rope.physicsBody = SKPhysicsBody.bodyWithRectangleOfSize(rope.size)
    rope.physicsBody.dynamic = false
    rope.physicsBody.affectedByGravity = false
    addChild rope

    y = (rope_width / device.screen_width).round
    y.times do |i|
      rope_part = SKSpriteNode.spriteNodeWithImageNamed('kids_menu/rope.png')
      rope_part.size = CGSizeMake(device.screen_width, rope.size.height)
      rope_part.anchorPoint = CGPointMake(0, 0.5)
      rope_part.position = CGPointMake(i * device.screen_width, 0)
      rope_part.zPosition = 0

      rope.addChild rope_part
    end

    @story_nodes.each do |node|
      joint = SKPhysicsJointPin.jointWithBodyA(node.physicsBody,
                                               bodyB:rope.physicsBody,
                                               anchor:CGPointMake(node.position.x, node.position.y+50))

      joint.lowerAngleLimit = -0.1
      joint.upperAngleLimit = 0.1
      joint.shouldEnableLimits = true
      joint.rotationSpeed = 0.1

      physicsWorld.addJoint(joint)
    end


  end

  def parent_button_clicked(button)
    parent_button_sequence = SKAction.sequence([SKAction.scaleTo(1.25, duration: 0.15),
                                                SKAction.waitForDuration(0.25, withRange: 0.05),
                                                SKAction.scaleTo(1, duration: 0.15),
                                                SKAction.waitForDuration(0.25, withRange: 0.05),
                                                SKAction.performSelector('close_kids_menu', onTarget: self)])
    button.runAction(parent_button_sequence)
  end

  def close_kids_menu
    StartScreen.next_screen = :age_verification_screen
    StartScreen.last_screen = :kids_menu
    rmq.screen.open_root_screen(StartScreen)
  end

  def move_rope_by_x(x_distance, duration)

    rope = self.childNodeWithName('rope')
    return if (rope.nil? || @story_nodes.empty?)

    center_node = @story_nodes.find{|node| node.center == true}

    return if center_node == @story_nodes.first && x_distance > 0
    return if center_node == @story_nodes.last && x_distance < 0

    rope.runAction(SKAction.moveByX(x_distance,y:0, duration: duration))
  end

end