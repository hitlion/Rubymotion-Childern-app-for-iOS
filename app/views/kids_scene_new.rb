class KidsSceneNew < SKScene

  def didMoveToView(view)
    super

    create_scene
  end

  def touchesBegan(touches, withEvent: event)
    super

    touch = touches.anyObject
    node = nodeAtPoint(touch.locationInNode(self))

    return unless node

    lp node.name

    case node.name
      when 'parent_button'
        parent_button_clicked(node)
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

    node = StoryNode.create_with_bundle(nil, size: CGSizeMake(0.25 * device.screen_height, 0.25 * device.screen_height))
    addChild node
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


end