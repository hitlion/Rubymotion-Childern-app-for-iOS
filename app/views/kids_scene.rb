class KidsScene < SKScene

  def didMoveToView(view)
    super

    physicsWorld.gravity = CGVectorMake(0.0, -100.0)
    physicsWorld.contactDelegate = self

    create_scene

    self.view.on(:swipe_right) do |sender, event|
      swipe_right(sender, event: event)
    end

    self.view.on(:swipe_left) do |sender, event|
     swipe_left(sender, event: event)
    end

    self.view.on(:tap) do |sender, event|
      taped(sender, event: event)
    end
  end

  def willMoveFromView(view)
    if @background_audio
      @background_audio.stop
      @background_audio = nil
    end

    self.view.off
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

    version = SKLabelNode.labelNodeWithFontNamed(rmq.font.pad_large.fontName)
    device.ipad? ? version.fontSize = rmq.font.pad_large.pointSize : version.fontSize = rmq.font.phone_large.pointSize
    version.fontColor = rmq.color.white
    version.text = app.version
    version.zPosition = 999_000
    version.position = CGPointMake(0.025 * device.screen_width , 0.025 * device.screen_height)
    addChild version

    unless @background_audio
      url = NSBundle.mainBundle.URLForResource("sounds/kids_background.mp3", withExtension:nil)

      @background_audio ||= AVAudioPlayer.alloc.initWithContentsOfURL(url, error:nil)
      @background_audio.numberOfLoops = -1
      @background_audio.prepareToPlay
      @background_audio.play
    end

    bundles = StoryBundle.bundles.select { |b| b.valid? }
    bundles.sort_by! { |k| k.document.timestamp}
    bundles.reverse!

    @story_nodes = []

    return unless bundles && bundles != []

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

    @story_nodes.first.runAction(SKAction.scaleTo(2, duration: 0.2))
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

  def scale_center_normal
    return unless @story_nodes

    center_node = @story_nodes.find{|node| node.center == true}
    return unless center_node
    center_node.runAction(SKAction.scaleTo(1, duration: 0.25))
  end

  def scale_center_big
    return unless @story_nodes

    center_node = @story_nodes.find{|node| node.center == true}
    return unless center_node
    return if center_node.xScale == 2

    @story_nodes.each do |node|
      node.runAction(SKAction.scaleTo(1, duration: 0.00))
    end

    center_node = @story_nodes.find{|node| node.center == true}
    return unless center_node
    center_node.runAction(SKAction.scaleTo(2, duration: 0.25))
  end

  def swipe_right(sender, event: event)
    direction = 1
    center_node = @story_nodes.find{|node| node.center == true}
    return unless center_node

    return if center_node == @story_nodes.first

    if center_node.xScale == 2 && center_node.yScale == 2
      scale_center_normal
    end

    rope = self.childNodeWithName('rope')
    return if (rope.nil? || @story_nodes.empty?)

    rope.runAction(SKAction.moveByX(direction * 0.4 * device.screen_width, y: 0, duration: 0.5), completion: -> {scale_center_big})
    i = @story_nodes.index {|node| node == center_node}
    next_node =  @story_nodes[i - direction]

    return unless next_node

    center_node.center = false
    next_node.center = true
  end

  def swipe_left(sender, event: event)
    direction = -1
    center_node = @story_nodes.find{|node| node.center == true}
    return unless center_node

    return if center_node == @story_nodes.last

    if center_node.xScale == 2 && center_node.yScale == 2
      scale_center_normal
    end

    rope = self.childNodeWithName('rope')
    return if (rope.nil? || @story_nodes.empty?)

    rope.runAction(SKAction.moveByX(direction * 0.4 * device.screen_width, y: 0, duration: 0.5), completion: -> {scale_center_big})

    i = @story_nodes.index {|node| node == center_node}
    next_node =  @story_nodes[i - direction]

    return unless next_node

    center_node.center = false
    next_node.center = true
  end

  def taped(sender, event: event)
    point = CGPointMake(event.location.x, device.screen_height - event.location.y)
    node = nodeAtPoint(point)
    return unless node

    if node.is_a? StoryNode
      node.start
    else
      case node.name
        when 'parent_button'
          parent_button_clicked(node)
      end
    end
  end

 end