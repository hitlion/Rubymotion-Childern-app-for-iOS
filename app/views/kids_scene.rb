class KidsScene < SKScene

  attr_accessor :story_list

  #####################
  # constants
  #####################

  # y position (in x * screen high)
  BUTTON_LINE_Y = 0.8
  ROPE_LINE_Y   = 0.6
  STORY_POS_Y = 0.6

  # x position (in x * screen width)
  CHILD_BUTTON_X  = 0.8
  PARENT_BUTTON_X = 0.2
  LOGO_BUTTON_X   = 0.5

  # Sizes (in x * screen high) for the folowing elements
  SIZE_CENTER_STORY  = 0.5
  SIZE_OTHER_STORY   = 0.25
  SIZE_BUTTON_LINE_ELEMENT = 0.25

  # Sprite node names
  BUTTON_PARENT_NAME = "PARENT"
  BUTTON_CHILD_NAME = "CHILD"
  BUTTON_LOGO_NAME = "LOGO"
  ELEMENT_STORY_NAME = "STORY"
  ELEMENT_ROPE_NAME = "ROPE"
  ELEMENT_BACKGROUND_NAME = "BACKGROUND"
  ELEMENT_USER_PICTURE = "USER PICTURE"

  # Font and fonstsize
  FONT_SIZE = 47
  FONT = "Enriqueta Regular"
  

  #####################
  # super class methods
  #####################

  ##
  # called when moved to this view
  #
  def didMoveToView(view)
    super

    if @init
      return
    end

    @init = false

    physicsWorld.gravity = CGVectorMake(0.0, -100.0)
    physicsWorld.contactDelegate = self

    init_values

    add_background

    add_element_in_buttonline("avatar_Kind", BUTTON_CHILD_NAME, CHILD_BUTTON_X, 10)
    add_element_in_buttonline("avatar_Vater", BUTTON_PARENT_NAME, PARENT_BUTTON_X, 10)
    add_element_in_buttonline("Logo", BUTTON_LOGO_NAME, LOGO_BUTTON_X, 10)

    add_story_list

    add_rope

    add_joints

    add_version_number

  end

  ##
  # called once every frame
  #
  def update(current_time)
    super

    if !@init
      return
    end

    @delta = @last_update_time ?  current_time - @last_update_time : 0
    @last_update_time = current_time

    #todo

    if (@story_list.select{|s| s.document.set_name == nodeAtPoint(@center_point).name}.first)
      @center_node = nodeAtPoint(@center_point)
    end
  end

  ##
  # Called when the touch started
  #
  def touchesBegan(touches, withEvent: event)
    super

    touch = touches.anyObject
    node = nodeAtPoint(touch.locationInNode(self))

    puts node.name

    if node.name == BUTTON_CHILD_NAME
      child_button_clicked
    elsif node.name == BUTTON_PARENT_NAME
      parent_button_clicked
    elsif node.name == BUTTON_LOGO_NAME
      printf("Logo button clicked \n")
    end

    story = @story_list.select{|s| s.document.set_name == @center_node.name}.first

    if @center_node.equal?(node)
      play_story(story)
    elsif (@story_list.select{|s| s.document.set_name == node.name}.first) && (!node.equal?(@center_node))
      scale_all_small
      move_rope_by_x(@center_point.x - node.position.x, 0.35)
      @center_node = node
    end
  end

  ##
  # Called when the touch moved
  #
  def touchesMoved(touches, withEvent: event)
    super

    scale_all_small

    touch = event.touchesForView(self.view).anyObject
    location = touch.locationInView(self.view)
    prev_location = touch.previousLocationInView(self.view)

    move_rope_by_x(location.x - prev_location.x, 0.01)
  end

  ##
  # Called when the touch ended
  #
  def touchesEnded(touches, withEvent: event)
    moveSequence = SKAction.sequence([SKAction.waitForDuration(0.35, withRange: 0.01),
                                      SKAction.performSelector("center_story_pics", onTarget: self),
                                      SKAction.waitForDuration(0.2, withRange: 0.05),
                                      SKAction.performSelector("scale_mid_big", onTarget: self)])

    self.runAction(moveSequence)

  end

  #######################
  # Methods
  #######################

  ##
  # This methods initialize the member variables
  #
  def init_values
    @story_list = StoryBundle.bundles.select { |b| b.valid? }
   # @story_list.sort{|s| s.document.timestamp}
    @height     ||= CGRectGetHeight(self.frame)
    @width      ||= CGRectGetWidth(self.frame)
    @rope_line  ||= @height * ROPE_LINE_Y
    @height_center_pic ||= @height * SIZE_CENTER_STORY
    @height_other_pic  ||= @height * SIZE_OTHER_STORY
  end

  ##
  # Creates sprite elements at the button line.
  # The height of this line is defined in the class constant BUTTON_LINE
  #
  # @param texture_name The name of the texture in the resources folder.
  # @param name The node name
  # @param x_pos The x position in % (0.XX) at the Button Line
  # @param z_pos The position in the z layer.
  #
  def add_element_in_buttonline (texture_name, name, x_pos, z_pos)
    element = SKSpriteNode.spriteNodeWithTexture(SKTexture.textureWithImageNamed(texture_name))
    element.name = name
    element.zPosition = z_pos
    element.position = CGPointMake(x_pos * @width, BUTTON_LINE_Y * @height)
    element.scale = ((@height * SIZE_BUTTON_LINE_ELEMENT) / (element.size.height))

    addChild element
  end

  ##
  # add story list
  #
  def add_story_list
    texture = SKTexture.textureWithImageNamed("Rahmen.png")

    @big_scale          ||= @height_center_pic / (texture.size.height)
    @small_scale        ||= @height_other_pic  / (texture.size.height)
    @story_pos_y        ||= STORY_POS_Y * @height
    @center_point       ||= CGPointMake(mid_x,@story_pos_y)
    @init               ||= true

    distance_between_storyicons ||= texture.size.width * 1.2 * @big_scale

    @story_list.each_with_index do |s,i|

      story = SKSpriteNode.spriteNodeWithColor(UIColor.clearColor, size: texture.size)

      story.scale = @small_scale
      story.zPosition = 10
      story.anchorPoint = CGPointMake(0.5, 0.98)
      story.position = CGPointMake(mid_x + i * distance_between_storyicons, @story_pos_y)

      story.name = s.document.set_name

      story.physicsBody = SKPhysicsBody.bodyWithRectangleOfSize(story.size)
      story.physicsBody.dynamic = true
      story.physicsBody.angularDamping = 5.0

      addChild story 
      
      story_frame = SKSpriteNode.spriteNodeWithTexture(texture)
      story_frame.zPosition = -2
      story_frame.anchorPoint = CGPointMake(0.5, 0)
      story_frame.position = CGPointMake(0, -texture.size.height)
      story.addChild story_frame

      story_picture = SKSpriteNode.spriteNodeWithTexture(SKTexture.textureWithImage (UIImage.imageWithData(s.asset_data(s.document.thumbnail))))
      story_picture.zPosition = -3
      story_picture.anchorPoint = CGPointMake(0.5, 0.5)
      story_picture.position = CGPointMake(0, - 0.63 * texture.size.height)
      story_picture.scale = (0.68 * texture.size.height) / story_picture.size.height
      story.addChild story_picture

      clip = SKSpriteNode.spriteNodeWithImageNamed("Klammer")
      clip.zPosition = -1
      clip.anchorPoint = CGPointMake(0.5, 0)
      clip.position = CGPointMake(0, - 0.05 * texture.size.height)
      clip.scale = (0.2 * texture.size.height) / clip.size.height
      story.addChild clip

      user_picture = SKSpriteNode.spriteNodeWithImageNamed("avatar_Vater")
      user_picture.zPosition = 1
      user_picture.position = CGPointMake(0.5 * texture.size.width, - 1 * texture.size.height)
      user_picture.scale = (0.35 * texture.size.height) / user_picture.size.height
      user_picture.name = ELEMENT_USER_PICTURE

      story.addChild user_picture

      label = SKLabelNode.labelNodeWithText(s.document.set_name)
      label.position = CGPointMake(0, - 0.35 * texture.size.height )
      label.zPosition = -1
      label.fontSize = FONT_SIZE
      label.fontColor = UIColor.blackColor
      label.fontName = FONT
      story.addChild label

    end

    if(!@story_list.empty?)
      @center_node = childNodeWithName(@story_list.first.document.set_name)
    end


    scale_all_small
    scale_mid_big
  end

  ##
  # Add joints
  #
  def add_joints

    @story_list.each do |s|
      joint = SKPhysicsJointPin.jointWithBodyA(childNodeWithName(s.document.set_name).physicsBody,
                                               bodyB:childNodeWithName(ELEMENT_ROPE_NAME).physicsBody,
                                               anchor:CGPointMake(childNodeWithName(s.document.set_name).position.x,
                                                                  childNodeWithName(s.document.set_name).position.y+50))

      joint.lowerAngleLimit = -0.1
      joint.upperAngleLimit = 0.1
      joint.shouldEnableLimits = true
      joint.rotationSpeed = 0.1

      physicsWorld.addJoint(joint)
    end
  end

  ##
  # Add and define the rope sprite
  #
  def add_rope

    return if @story_list.empty?

    rope_width = childNodeWithName(@story_list.last.document.set_name).position.x - childNodeWithName(@story_list.first.document.set_name).position.x + 3 * device.screen_width

    rope = SKSpriteNode.spriteNodeWithColor(UIColor.clearColor, size: CGSizeMake(rope_width, @height / 100))
    rope.name = ELEMENT_ROPE_NAME
    rope.zPosition = 0

    rope.position = CGPointMake(- @width, ROPE_LINE_Y * @height)
    rope.anchorPoint = CGPointMake(0.0, 0.5)

    rope.physicsBody = SKPhysicsBody.bodyWithRectangleOfSize(rope.size)
    rope.physicsBody.dynamic = false
    rope.physicsBody.affectedByGravity = false

    addChild rope

    texture = SKTexture.textureWithImageNamed("Seil.png")

    width = device.screen_width

    y = (rope_width / width).round

    y.times do |i|
      rope_part = SKSpriteNode.spriteNodeWithTexture(texture)
      rope_part.size = CGSizeMake(width,15)
      rope_part.anchorPoint = CGPointMake(0,0.5)
      rope_part.position = CGPointMake (0 + i * 1024 , 0)
      rope_part.zPosition = 0

      rope.addChild rope_part
    end
   # TODO Länge der Sprites generisch gestalten
  end

  ##
  # Add and define the background sprite
  #
  def add_background
    texture = SKTexture.textureWithImageNamed("BG.png")

    background = SKSpriteNode.spriteNodeWithTexture(texture)
    background.position = CGPointMake(mid_x, mid_y)
    background.name = ELEMENT_BACKGROUND_NAME
    background.zPosition = -10

    background.size = CGSizeMake(@width,@height)

    addChild background
  end

  def add_version_number
    label = SKLabelNode.labelNodeWithText(app.version)
    label.position = CGPointMake(30,10)
    label.zPosition = 100
    label.fontSize = 15
    label.fontColor = UIColor.blackColor
    label.fontName = FONT
    addChild label
  end

  #################
  # Touch Event / clicked Methods
  #################
  def parent_button_clicked
    StartScreen.next_screen = :age_verification_screen
    StartScreen.last_screen = :kids_menu
    rmq.screen.open_root_screen(StartScreen)
  end

  def child_button_clicked
    #TODO Kindermenue
  end

  # Start the +StoryPlayerScreen+ displaying a given +StoryBundle+
  def play_story( story )
    StartScreen.next_story = story
    StartScreen.next_screen = :story_player
    StartScreen.last_screen = :kids_menu
    rmq.screen.open_root_screen(StartScreen)
  end
  ############################
  # Helper and action methods.
  ############################

  ##
  # This method moves the rope by x pixel in the given duration
  # param x_distance The distance in Pixel, with direction (+ or -)
  # param duration The duration for this animation
  #
  def move_rope_by_x(x_distance, duration)

    rope = self.childNodeWithName(ELEMENT_ROPE_NAME)

    return if (rope.nil? || @story_list.empty?)

    if @center_node.equal?(childNodeWithName(@story_list.first.document.set_name)) &&
        childNodeWithName(@story_list.first.document.set_name).position == @center_point && x_distance >= 0
      return
    end

    if @center_node.equal?(childNodeWithName(@story_list.last.document.set_name)) &&
        childNodeWithName(@story_list.last.document.set_name).position == @center_point && x_distance <= 0
      return
    end

    rope = self.childNodeWithName(ELEMENT_ROPE_NAME)
    rope.runAction(SKAction.moveByX(x_distance,y:0, duration: duration))
  end

  ##
  # Get the mid x value of the screen
  #
  def mid_x
    CGRectGetMidX(self.frame)
  end

  ##
  # Get the mid y value of the screen
  #
  def mid_y
    CGRectGetMidY(self.frame)
  end

  ##
  # Set the scale property of the current @center_node to @big_scale and
  #
  def scale_mid_big
    scale_all_small
    if(!@center_node.nil?)
      @center_node.scale = @big_scale
    end
  end

  ##
  # Set the scale property from all elements of the @stories array to @small_scale
  #
  def scale_all_small
    if(!@story_list.empty?)
      @story_list.each do |s|
        childNodeWithName(s.document.set_name).scale = @small_scale
      end
    end
  end

  ##
  # If the current position of the @center_node is not the @center_point, than move the rope
  # by the diff between these two points
  def center_story_pics

    return if @center_node.nil? || !@init

    if @init && @center_node.position != @center_point
      move_rope_by_x(@center_point.x - @center_node.position.x,0.05)
    end
  end


end