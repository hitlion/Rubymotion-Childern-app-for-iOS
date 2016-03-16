class SmartphoneOverlayView < UIView

  attr_accessor :story
  attr_accessor :overlay_type

  ##
  # Identifier for all cells
  CellIdentifier = 'Cell'

  def init_with_type(type, frame: frame)
    self.initWithFrame(frame)
    @story = nil
    @overlay_type = type

    @text_top_button_left   = type.text_top_button_left
    @text_top_button_right  = type.text_top_button_right
    @text_top_button_line_1 = type.text_top_button_line_1
    @text_top_button_line_2 = type.text_top_button_line_2
    @text_top_button_line_3 = type.text_top_button_line_3
    @text_top_button_line_4 = type.text_top_button_line_4
    @text_top_button_line_5 = type.text_top_button_line_5

    @text_bottom_button_line_1 = type.text_bottom_button_line_1
    @text_bottom_button_line_2 = type.text_bottom_button_line_2

    self
  end

  def reload_view_with_story(story)
    @story = story
    build_view
  end

  def build_view

    self.subviews.each do |v|
      v.removeFromSuperview
    end

    background_view = UIImageView.alloc.initWithFrame(CGRectMake(0,0,
                                                           self.frame.size.width+1, self.frame.size.height))
    background_view.image = UIImage.imageNamed("background_grey_trans.png")

    overlay_view = UIView.alloc.initWithFrame(CGRectMake(0.166 * self.frame.size.width, 0 * self.frame.size.height,
                                                        0.66 * self.frame.size.width, 1 * self.frame.size.height))
    overlay_view.backgroundColor = UIColor.whiteColor

    button_size = CGSizeMake((1.0 / 5.0) * overlay_view.frame.size.width, (1.75 / 30.0) * overlay_view.frame.size.height)

    ####
    # Build the bottom view (all over the horizontal line)
    top_view = UIView.alloc.initWithFrame(CGRectMake(0, 0,
                                                    overlay_view.frame.size.width, 0.4 * overlay_view.frame.size.height))
    top_view.backgroundColor = UIColor.clearColor

    ###
    # Define the story image
    image = UIImageView.alloc.initWithFrame(CGRectMake(0.05 * top_view.frame.size.width, 0.1 * top_view.frame.size.height,
                                                       0.3 * top_view.frame.size.width, 0.6 * top_view.frame.size.height))
    image.image = UIImage.imageWithData(story.asset_data(story.document.thumbnail))
    top_view.addSubview(image)

    ###
    # Define the name label
    name = UILabel.alloc.initWithFrame(CGRectMake(0.4 * top_view.frame.size.width, 0.1 * top_view.frame.size.height,
                                                       0.45 * top_view.frame.size.width, 0.15 * top_view.frame.size.height))
    name.text = story.document.set_name
    name.textColor = rmq.color.babbo_orange
    name.font = UIFont.fontWithName(TTUtil.get_font_standard(:bold), size: TTUtil.get_font_size(:large))
    name.textAlignment = UITextAlignmentLeft
    top_view.addSubview(name)

    ###
    # Define the timestamp
    date = UILabel.alloc.initWithFrame(CGRectMake(0.4 * top_view.frame.size.width, 0.25 * top_view.frame.size.height,
                                                   0.3 * top_view.frame.size.width, 0.15 * top_view.frame.size.height))
    time = Time.at(NSDate.dateWithNaturalLanguageString(story.document.timestamp))
    date.text = time.strftime("%d. %B %Y").to_s
    date.textColor = UIColor.blackColor
    date.font = UIFont.fontWithName(TTUtil.get_font_standard(:regular), size: TTUtil.get_font_size(:medium))
    date.textAlignment = UITextAlignmentLeft
    top_view.addSubview(date)

    ###
    # Define left button
    left_button = UIButton.alloc.initWithFrame(CGRectMake(0.4 * top_view.frame.size.width, 0.5 * top_view.frame.size.height,
                                                          button_size.width, button_size.height))
    left_button.setBackgroundImage(UIImage.imageNamed("button_orange.png"), forState:UIControlStateNormal)
    left_button.setTitle(@text_top_button_left, forState: UIControlStateNormal)
    left_button.addTarget(self, action: "left_button_pressed:", forControlEvents: UIControlEventTouchUpInside)
    left_button.font = UIFont.fontWithName(TTUtil.get_font_standard(:regular), size: TTUtil.get_font_size(:small))
    left_button.tag = story.object_id
    top_view.addSubview(left_button)

    ###
    # Define right button
    right_button = UIButton.alloc.initWithFrame(CGRectMake(0.65 * top_view.frame.size.width,0.5 * top_view.frame.size.height,
                                                           button_size.width, button_size.height))
    right_button.setBackgroundImage(UIImage.imageNamed("button_grey.png"), forState:UIControlStateNormal)
    right_button.setTitle(@text_top_button_right, forState: UIControlStateNormal)
    right_button.addTarget(self, action: "right_button_pressed:", forControlEvents: UIControlEventTouchUpInside)
    right_button.font = UIFont.fontWithName(TTUtil.get_font_standard(:regular), size: TTUtil.get_font_size(:small))

    if(@overlay_type.class == OverlayShopPremium)
      top_view.addSubview(right_button)
    end


    ###
    # Define cancel button
    cancel_button = UIButton.alloc.initWithFrame(CGRectMake(0.9 * top_view.frame.size.width,0.1 * top_view.frame.size.height,
    cancel_button.setBackgroundImage(UIImage.imageNamed("icon_close_black.png"), forState:UIControlStateNormal)
    cancel_button.addTarget(self, action: "cancel_button_pressed:", forControlEvents: UIControlEventTouchUpInside)
    top_view.addSubview(cancel_button)

    ###
    # Build top button line
    top_button_line = UIView.alloc.initWithFrame(CGRectMake(0.2 * top_view.frame.size.width, 0.775 * top_view.frame.size.height,
                                                            3.0 * button_size.width, button_size.height))
    ##
    # Define the first button
    top_button_line_1 = UIButton.alloc.initWithFrame(CGRectMake(0 * button_size.width, 0,
                                                                 button_size.width, button_size.height))
    top_button_line_1.setBackgroundImage(UIImage.imageNamed("button_bg_left_white.png"), forState:UIControlStateNormal)
    top_button_line_1.setTitle(@text_top_button_line_1, forState: UIControlStateNormal)
    top_button_line_1.addTarget(self, action: "top_button_line_pressed:", forControlEvents: UIControlEventTouchUpInside)
    top_button_line_1.font = UIFont.fontWithName(TTUtil.get_font_standard(:regular), size: TTUtil.get_font_size(:small))
    top_button_line_1.setTitleColor(UIColor.blackColor, forState: UIControlStateNormal)
    top_button_line_1.setTitleColor(UIColor.whiteColor, forState: UIControlStateHighlighted)
    top_button_line_1.tag = 0

    ##
    # Define the second button
    top_button_line_2 = UIButton.alloc.initWithFrame(CGRectMake(1 * button_size.width, 0,
                                                                button_size.width, button_size.height))
    top_button_line_2.setBackgroundImage(UIImage.imageNamed("button_bg_middle_white.png"), forState:UIControlStateNormal)
    top_button_line_2.setTitle(@text_top_button_line_2, forState: UIControlStateNormal)
    top_button_line_2.addTarget(self, action: "top_button_line_pressed:", forControlEvents: UIControlEventTouchUpInside)
    top_button_line_2.font = UIFont.fontWithName(TTUtil.get_font_standard(:regular), size: TTUtil.get_font_size(:small))
    top_button_line_2.setTitleColor(UIColor.blackColor, forState: UIControlStateNormal)
    top_button_line_2.setTitleColor(UIColor.whiteColor, forState: UIControlStateHighlighted)
    top_button_line_2.tag = 1

    ##
    # Define the third button
    top_button_line_3 = UIButton.alloc.initWithFrame(CGRectMake(2 * button_size.width, 0,
                                                                button_size.width, button_size.height))
    top_button_line_3.setBackgroundImage(UIImage.imageNamed("button_bg_right_white.png"), forState:UIControlStateNormal)
    top_button_line_3.setTitle(@text_top_button_line_3, forState: UIControlStateNormal)
    top_button_line_3.addTarget(self, action: "top_button_line_pressed:", forControlEvents: UIControlEventTouchUpInside)
    top_button_line_3.font = UIFont.fontWithName(TTUtil.get_font_standard(:regular), size: TTUtil.get_font_size(:small))
    top_button_line_3.setTitleColor(UIColor.blackColor, forState: UIControlStateNormal)
    top_button_line_3.setTitleColor(UIColor.whiteColor, forState: UIControlStateHighlighted)
    top_button_line_3.tag = 2

    top_button_line.addSubview(top_button_line_1)
    top_button_line.addSubview(top_button_line_2)
    top_button_line.addSubview(top_button_line_3)

    if(@overlay_type.class == OverlayMenuStandard)
      top_view.addSubview(top_button_line)
    end

    ###
    # Define the horizontal line
    line = UIView.alloc.initWithFrame(CGRectMake(0.05 * top_view.frame.size.width, top_view.frame.size.height - 1 ,
                                                 0.9 * top_view.frame.size.width, 1))
    line.backgroundColor = rmq.color.babbo_line_grey
    top_view.addSubview(line)

    ####
    # Build the bottom view (all under the horizontal line)
    bottom_view = UIView.alloc.initWithFrame(CGRectMake(0,0.4 * overlay_view.frame.size.height,
                                                        overlay_view.frame.size.width, 0.6 * overlay_view.frame.size.height))
    bottom_view.backgroundColor = UIColor.clearColor

    ###
    # The button line
    bottom_button_line = UIView.alloc.initWithFrame(CGRectMake(0.3 * bottom_view.frame.size.width, 0.05 * bottom_view.frame.size.height,
                                                               2.0 * button_size.width, button_size.height))

    ##
    # The left button
    bottom_left_button = UIButton.alloc.initWithFrame(CGRectMake(0 * button_size.width, 0,
                                                                 button_size.width, button_size.height))
    bottom_left_button.setBackgroundImage(UIImage.imageNamed("button_bg_left_grey.png"), forState:UIControlStateNormal)
    bottom_left_button.setTitle(@text_bottom_button_line_1, forState: UIControlStateNormal)
    bottom_left_button.addTarget(self, action: "bottom_button_line_pressed:", forControlEvents: UIControlEventTouchUpInside)
    bottom_left_button.font = UIFont.fontWithName(TTUtil.get_font_standard(:regular), size: TTUtil.get_font_size(:small))
    bottom_left_button.setTitleColor(UIColor.whiteColor, forState: UIControlStateNormal)
    bottom_left_button.setTitleColor(UIColor.blackColor, forState: UIControlStateHighlighted)
    bottom_left_button.tag = 0
    @bottom_button_line_selected = bottom_left_button

    ##
    # The right button
    bottom_right_button = UIButton.alloc.initWithFrame(CGRectMake(1 * button_size.width, 0,
                                                                 button_size.width, button_size.height))
    bottom_right_button.setBackgroundImage(UIImage.imageNamed("button_bg_right_white.png"), forState:UIControlStateNormal)
    bottom_right_button.setTitle(@text_bottom_button_line_2, forState: UIControlStateNormal)
    bottom_right_button.addTarget(self, action: "bottom_button_line_pressed:", forControlEvents: UIControlEventTouchUpInside)
    bottom_right_button.font = UIFont.fontWithName(TTUtil.get_font_standard(:regular), size: TTUtil.get_font_size(:small))
    bottom_right_button.setTitleColor(UIColor.blackColor, forState: UIControlStateNormal)
    bottom_right_button.setTitleColor(UIColor.whiteColor, forState: UIControlStateHighlighted)
    bottom_right_button.tag = 1

    bottom_button_line.addSubview(bottom_left_button)
    bottom_button_line.addSubview(bottom_right_button)
    bottom_view.addSubview(bottom_button_line)

    ###
    # Define the screenshot collection view

    @screenshots = ServerBackend.get.screenshots_for_story(story)
    layout = UICollectionViewFlowLayout.alloc.init
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal

    frame = CGRectMake(0.025 * bottom_view.frame.size.width, 0.2 * bottom_view.frame.size.height,
                       0.95  * bottom_view.frame.size.width, 0.7 * bottom_view.frame.size.height )

    @screenshot_collection_view = UICollectionView.alloc.initWithFrame(frame, collectionViewLayout: layout)
    @screenshot_collection_view.dataSource = self
    @screenshot_collection_view.delegate = self

    height = @screenshot_collection_view.frame.size.height
    width  = (4 * height) / 3
    size = CGSizeMake(width, height)

    layout.itemSize = size

    @screenshot_collection_view.contentInset = UIEdgeInsetsMake(0, 0 * @screenshot_collection_view.frame.size.width,
                                                           0, 0 * @screenshot_collection_view.frame.size.width)

    @screenshot_collection_view.registerClass(OverlayScreenshotCell, forCellWithReuseIdentifier: CellIdentifier)
    @screenshot_collection_view.backgroundColor = UIColor.clearColor
    @screenshot_collection_view.hidden = true

    bottom_view.addSubview(@screenshot_collection_view)


    ###
    # Build the textfield
    @text_view = UITextView.alloc.initWithFrame(frame)
    @text_view.font = UIFont.fontWithName(TTUtil.get_font_standard(:regular), size: TTUtil.get_font_size(:small))
    @text_view.textAlignment = UITextAlignmentLeft

    @text_view.text = ServerBackend.get.description_for_story(story)
    bottom_view.addSubview(@text_view)

    ####
    # add views
    overlay_view.addSubview(top_view)
    overlay_view.addSubview(bottom_view)

    self.addSubview(background_view)
    self.addSubview(overlay_view)
  end

  def left_button_pressed(button)

    if(@overlay_type.class == OverlayMenuStandard)
      StartScreen.next_story = @story
      StartScreen.next_screen = :story_player
      StartScreen.last_screen = :parent_menu
      rmq.screen.open_root_screen(StartScreen)
    end

  end

  def right_button_pressed(button)

  end

  def cancel_button_pressed(button)
    self.hidden = true
  end

  def edit_story
    if @story.ruleset.rules.empty?
      app.alert(title: 'Entschuldigung',
                message: 'Diese Story kann nicht bearbeitet werden.')
    else
      StartScreen.next_story = @story
      StartScreen.next_screen = :story_editor
      StartScreen.last_screen = :parent_menu
      StartScreen.editor_mode = :edit
      rmq.screen.open_root_screen(StartScreen)
    end
  end

  def remove_story
    app.alert(title: "Achtung!", message: "Wollen sie diese Story wirklich löschen", actions: ['JA', 'NEIN']) do |button_tag|
      case button_tag
        when 'JA'
          NSFileManager.defaultManager.removeItemAtPath(@story.path, error:nil)
          StoryBundle.delete_story(@story)
          StartScreen.next_screen = :parent_menu
          StartScreen.last_screen = :parent_menu
          rmq.screen.open_root_screen(StartScreen)
        when 'NEIN'
      end
    end
  end

  def new_story
    if @story.ruleset.rules.empty?
      app.alert(title: 'Entschuldigung',
                message: 'Diese Story kann nicht bearbeitet werden.')
    else
      StartScreen.next_story = @story
      StartScreen.next_screen = :story_editor
      StartScreen.last_screen = :parent_menu
      StartScreen.editor_mode = :new
      rmq.screen.open_root_screen(StartScreen)
    end
  end

  def show_screenshoots
    @text_view.hidden = true
    @screenshot_collection_view.hidden = false
  end

  def show_description
    @text_view.hidden = false
    @screenshot_collection_view.hidden = true
  end


  ##
  # called if one of the buttons in the top button line ie pressed
  def top_button_line_pressed(element)
    if (@overlay_type.class == OverlayMenuStandard)
      edit_story   if element.tag == 0
      new_story    if element.tag == 1
      remove_story if element.tag == 2
    end
  end

  ##
  # called if one of the buttons in the bottom button line ie pressed
  def bottom_button_line_pressed(element)

    if(element.tag == 0)
      image = UIImage.imageNamed("button_bg_left_grey.png")
    else
      image = UIImage.imageNamed("button_bg_right_grey.png")
    end

    element.setBackgroundImage(image, forState:UIControlStateNormal)
    element.setTitleColor(UIColor.whiteColor, forState: UIControlStateNormal)
    element.setTitleColor(UIColor.blackColor, forState: UIControlStateHighlighted)

    if(@bottom_button_line_selected.tag == 0)
      image = UIImage.imageNamed("button_bg_left_white.png")
    else
      image = UIImage.imageNamed("button_bg_right_white.png")
    end

    @bottom_button_line_selected.setBackgroundImage(image, forState:UIControlStateNormal)
    @bottom_button_line_selected.setTitleColor(UIColor.blackColor, forState: UIControlStateNormal)
    @bottom_button_line_selected.setTitleColor(UIColor.whiteColor, forState: UIControlStateHighlighted)

    @bottom_button_line_selected = element

    show_description    if element.tag == 0
    show_screenshoots   if element.tag == 1
  end

  # UICollectionView Instance Methods
  def collectionView(view, numberOfItemsInSection:section)

    if(view == @screenshot_collection_view)
      return @screenshots.length if(!@screenshots.nil?)
    end

    return 0
  end

  def collectionView(view, cellForItemAtIndexPath:path)
    cell = view.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: path)

    if(view == @screenshot_collection_view)
       screenshot = @screenshots[path.row]
       cell.delegate = self
       cell.make_cell(screenshot)
    end

    cell
  end
end
