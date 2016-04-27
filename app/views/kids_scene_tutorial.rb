class KidsSceneTutorial < SKScene

  #####################
  # super class methods
  #####################

    ##
  # called when moved to this view
  #
  def didMoveToView(view)
    super

    build_view
  end

  def willMoveFromView(view)
    lp 'test'
  end

  ##
  # called once every frame
  #
  def update(current_time)
    super

  end

  ##
  # Called when the touch started
  #
  def touchesBegan(touches, withEvent: event)
    super

    touch = touches.anyObject
    node = nodeAtPoint(touch.locationInNode(self))

    return if (node.nil?)



  end

  #######################
  # Methods
  #######################

  def build_view

    h = device.screen_height
    w = device.screen_width

    texture = SKTexture.textureWithImageNamed('test_image.png.png')

    background = SKSpriteNode.spriteNodeWithTexture(texture)
    background.position = CGPointMake(0.5 * w, 0.5 * h)
    background.name = 'background'
    background.zPosition = 0
    background.size = CGSizeMake(w, h)

    layer = SKSpriteNode.spriteNodeWithColor(rmq.color.white, size: CGSizeMake(w,h))
    layer.position =  CGPointMake(0.5 * w, 0.5 * h)
    layer.name = 'layer'
    layer.zPosition = 1
    layer.alpha = 0.5

    video_frame = SKSpriteNode.spriteNodeWithColor(rmq.color.white, size:  CGSizeMake(0.82 * w, 0.82 * h))
    video_frame.position =  CGPointMake(0.5 * w, 0.5 * h)
    video_frame.name = 'video_frame'
    video_frame.zPosition = 2

    video = SKSpriteNode.spriteNodeWithColor(rmq.color.blue, size:  CGSizeMake(0.8 * w, 0.8 * h))
    video.position =  CGPointMake(0.5 * w, 0.5 * h)
    video.name = 'video'
    video.zPosition = 3

    label_layer = SKSpriteNode.spriteNodeWithColor(rmq.color.babbo_orange, size: CGSizeMake(0.8 * w, 0.05 * h))
    label_layer.position =  CGPointMake(0.5 * w, 0.125 * h)
    label_layer.name = 'layer'
    label_layer.zPosition = 4

    label = SKLabelNode.labelNodeWithText('Beim nächstem Öffnen nicht erneut anzeigen')
    label.color = rmq.color.babbo_orange
    label.position = CGPointMake(0.175 * w, 0.1125 * h)
    label.name = 'label'
    label.zPosition = 5
    label.fontSize = TTUtil.get_font_size(:large)
    label.fontColor = rmq.color.white
    label.fontName = TTUtil.get_font_standard(:bold)
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft

    texture = SKTexture.textureWithImageNamed('babbo_icons/close.png')
    close = SKSpriteNode.spriteNodeWithTexture(texture)
    close.position = CGPointMake(0.85 * w, 0.825 * h)
    close.name = 'close'
    close.zPosition = 4
    close.size = CGSizeMake(0.075 * h, 0.075 * h)

    addChild background
    addChild layer
    addChild video_frame
    addChild video
    addChild label_layer
    addChild label
    addChild close
  end

end
