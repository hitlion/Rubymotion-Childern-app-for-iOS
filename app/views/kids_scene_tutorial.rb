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

    lp node.name

    case node.name
      when 'close'
        close_tutorial
      when 'hook'
        toogle_hook
      when 'check_box'
        toogle_hook
    end

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

    video = SKVideoNode.videoNodeWithFileNamed('tutorial/video.mp4')
    video.position =  CGPointMake(0.5 * w, 0.5 * h)
    video.name = 'video'
    video.zPosition = 3
    video.size = CGSizeMake(0.8 * w, 0.8 * h)

    texture = SKTexture.textureWithImageNamed('tutorial/tut_label_background.png')
    label_layer = SKSpriteNode.spriteNodeWithTexture(texture)
    label_layer.position =  CGPointMake(0.5 * w, 0.1325 * h)
    label_layer.name = 'layer'
    label_layer.zPosition = 4
    label_layer.size = CGSizeMake(0.75 * w, 0.06 * h)

    label = SKLabelNode.labelNodeWithText('Beim nächstem Öffnen nicht erneut anzeigen')
    label.color = rmq.color.babbo_orange
    label.position = CGPointMake(0.175 * w, 0.115 * h)
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

    texture = SKTexture.textureWithImageNamed('tutorial/tut_checkbox.png')
    check_box = SKSpriteNode.spriteNodeWithTexture(texture)
    check_box.position =  CGPointMake(0.8 * w, 0.1325 * h)
    check_box.name = 'check_box'
    check_box.zPosition = 6
    check_box.size = CGSizeMake(0.045 * h, 0.045 * h)

    texture = SKTexture.textureWithImageNamed('tutorial/tut_hook.png')
    hook = SKSpriteNode.spriteNodeWithTexture(texture)
    hook.position =  CGPointMake(0.8 * w, 0.1325 * h)
    hook.name = 'hook'
    hook.zPosition = 7
    hook.hidden = true
    hook.size = CGSizeMake(0.045 * h, 0.045 * h)

    addChild background
    addChild layer
    addChild video_frame
    addChild video
    addChild label_layer
    addChild label
    addChild close
    addChild check_box
    addChild hook
  end

  def toogle_hook
    hook = childNodeWithName('hook')
    hook.hidden = !hook.hidden?
    NSUserDefaults.standardUserDefaults.setBool(!hook.hidden?, forKey:'babbo_voco.hide_tutorial')
    NSUserDefaults.standardUserDefaults.synchronize
  end

  def close_tutorial
    lp 'close'

    NSNotificationCenter.defaultCenter.postNotificationName('TutorialClosed',
                                                            object:nil)

  end


end
