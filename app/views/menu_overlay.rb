class MenuOverlay < UIView

  attr_accessor :story
  attr_accessor  :overlay_type

  def initWithFrame(frame)
    super(frame)

    @babbo_bar_grey = UIColor.colorWithRed(247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha:1.0)
    @babbo_line_grey = UIColor.colorWithRed(200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha:1.0)
    @babbo_orange = UIColor.colorWithRed(249.0/255.0, green: 188.0/255.0, blue: 52.0/255.0, alpha:1.0)

    @textButtonLeft = "Dummy"
    @textButtonRight = "Dummy"

    self
  end

  def reloadViewWithStory(story)
    @story = story

    buildView
  end

  def buildView

    self.subviews.each do |v|
      v.removeFromSuperview
    end

    backgroundView = UIImageView.alloc.initWithFrame(CGRectMake(0,0,
                                                           self.frame.size.width, self.frame.size.height))
    backgroundView.image = UIImage.imageNamed("background_grey_trans.png")

    overlayView = UIView.alloc.initWithFrame(CGRectMake(0.2 * self.frame.size.width, 0.15 * self.frame.size.height,
                                                        0.6 * self.frame.size.width, 0.75 * self.frame.size.height))
    overlayView.backgroundColor = UIColor.whiteColor

    buttonSize = CGSizeMake(0.2 * overlayView.frame.size.width, 0.05 * overlayView.frame.size.height)

    topView = UIView.alloc.initWithFrame(CGRectMake(0, 0,
                                                    overlayView.frame.size.width, 0.4 * overlayView.frame.size.height))
    topView.backgroundColor = UIColor.clearColor

    image = UIImageView.alloc.initWithFrame(CGRectMake(0.05 * topView.frame.size.width, 0.1 * topView.frame.size.height,
                                                       0.3 * topView.frame.size.width, 0.6 * topView.frame.size.height))
    image.image = UIImage.imageWithData(story.asset_data(story.document.thumbnail))

    name = UILabel.alloc.initWithFrame(CGRectMake(0.4 * topView.frame.size.width, 0.1 * topView.frame.size.height,
                                                       0.45 * topView.frame.size.width, 0.15 * topView.frame.size.height))
    name.text = story.document.set_name
    name.textColor = @babbo_orange
    name.font = UIFont.fontWithName("Enriqueta-Bold", size:30)
    name.textAlignment = UITextAlignmentLeft

    date = UILabel.alloc.initWithFrame(CGRectMake(0.4 * topView.frame.size.width, 0.25 * topView.frame.size.height,
                                                   0.3 * topView.frame.size.width, 0.15 * topView.frame.size.height))
    time = Time.at(NSDate.dateWithNaturalLanguageString(story.document.timestamp))
    date.text = time.strftime("%d. %B %Y").to_s
    date.textColor = UIColor.blackColor
    date.font = UIFont.fontWithName("Enriqueta-Regular", size:15)
    date.textAlignment = UITextAlignmentLeft

    if(@overlay_type == :parent_menu)
      @textButtonLeft = "Starten"
    end

    left_button = UIButton.alloc.initWithFrame(CGRectMake(0.4 * topView.frame.size.width, 0.5 * topView.frame.size.height,
                                                          buttonSize.width, buttonSize.height))
    left_button.setBackgroundImage(UIImage.imageNamed("button_orange.png"), forState:UIControlStateNormal)
    left_button.setTitle(@textButtonLeft, forState: UIControlStateNormal)
    left_button.addTarget(self, action: "left_button_pressed:", forControlEvents: UIControlEventTouchUpInside)
    left_button.font = UIFont.fontWithName("Enriqueta-Regular", size:20)
    left_button.tag = story.object_id

    right_button = UIButton.alloc.initWithFrame(CGRectMake(0.65 * topView.frame.size.width,0.5 * topView.frame.size.height,
                                                           0.2 * topView.frame.size.width, 0.15 * topView.frame.size.height))
    right_button.setBackgroundImage(UIImage.imageNamed("button_grey.png"), forState:UIControlStateNormal)
    right_button.setTitle(@textButtonRight, forState: UIControlStateNormal)
    right_button.addTarget(self, action: "right_button_pressed:", forControlEvents: UIControlEventTouchUpInside)
    right_button.font = UIFont.fontWithName("Enriqueta-Regular", size:20)

    if(@overlay_type == :parent_menu)
      right_button.hidden = true
    end

    cancel_button = UIButton.alloc.initWithFrame(CGRectMake(0.9 * topView.frame.size.width,0.1 * topView.frame.size.height,
                                                          0.05 * topView.frame.size.width, 0.05 * topView.frame.size.width))
    cancel_button.setBackgroundImage(UIImage.imageNamed("icon_close_black.png"), forState:UIControlStateNormal)
    cancel_button.addTarget(self, action: "cancel_button_pressed:", forControlEvents: UIControlEventTouchUpInside)

    @buttons_in_top_button_line = ["Bearbeiten", "Neu", "Löschen"]

    text_attributes = { NSFontAttributeName => UIFont.fontWithName("Enriqueta-Regular", size:17) }

    button_line = UISegmentedControl.alloc.initWithItems(@buttons_in_top_button_line)
    button_line.frame = CGRectMake(0.2 * topView.frame.size.width, 0.775 * topView.frame.size.height,
                                   3 * buttonSize.width, buttonSize.height)
    button_line.addTarget(self, action: "button_line_top_value_changed:", forControlEvents: UIControlEventValueChanged)
    button_line.selectedSegmentIndex = -1
    button_line.segmentedControlStyle = UISegmentedControlStylePlain
    button_line.setTitleTextAttributes(text_attributes, forState: UIControlStateNormal)


    line = UIView.alloc.initWithFrame(CGRectMake(0.05 * topView.frame.size.width, topView.frame.size.height - 1 ,
                                                 0.9 * topView.frame.size.width, 1))
    line.backgroundColor = @babbo_line_grey

    topView.addSubview(image)
    topView.addSubview(name)
    topView.addSubview(date)
    topView.addSubview(left_button)
    topView.addSubview(right_button)
    topView.addSubview(cancel_button)
    topView.addSubview(button_line)
    topView.addSubview(line)

    bottomView = UIView.alloc.initWithFrame(CGRectMake(0,0.4 * overlayView.frame.size.height,
                                                           overlayView.frame.size.width, 0.6 * overlayView.frame.size.height))
    bottomView.backgroundColor = UIColor.clearColor

    @buttons_in_bottom_button_line = ["Bilder", "Beschreibung"]
    buttonLineBottom = UISegmentedControl.alloc.initWithItems(@buttons_in_bottom_button_line)
    buttonLineBottom.frame = CGRectMake(0.3 * bottomView.frame.size.width, 0.05 * bottomView.frame.size.height,
                                   2 * buttonSize.width, buttonSize.height)
    buttonLineBottom.addTarget(self, action: "button_line_bottom_value_changed:", forControlEvents: UIControlEventValueChanged)
    buttonLineBottom.selectedSegmentIndex = 1
    buttonLineBottom.segmentedControlStyle = UISegmentedControlStylePlain
    buttonLineBottom.setTitleTextAttributes(text_attributes, forState: UIControlStateNormal)

    @textView = UITextView.alloc.initWithFrame(CGRectMake(0.05 * bottomView.frame.size.width, 0.25 * bottomView.frame.size.height,
                                                          0.9 * bottomView.frame.size.width, 0.7 * bottomView.frame.size.height ))
    @textView.font = UIFont.fontWithName("Enriqueta-Regular", size:17)
    @textView.textAlignment = UITextAlignmentLeft

    @textView.text = story.document.description

    bottomView.addSubview(buttonLineBottom)
    bottomView.addSubview(@textView)

    overlayView.addSubview(topView)
    overlayView.addSubview(bottomView)

    self.addSubview(backgroundView)
    self.addSubview(overlayView)
  end

  def left_button_pressed(button)

    if(@overlay_type == :parent_menu)
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

  end

  def remove_story

  end

  def new_story

  end

  def show_screenshoots
    @textView.hidden = true
  end

  def show_description
    @textView.hidden = false
  end

  def button_line_top_value_changed(element)
    if (@overlay_type == :parent_menu)
      edit_story   if element.selectedSegmentIndex == 0
      new_story    if element.selectedSegmentIndex == 1
      remove_story if element.selectedSegmentIndex == 2
    end
  end

  def button_line_bottom_value_changed(element)
    if (@overlay_type == :parent_menu)
      show_screenshoots   if element.selectedSegmentIndex == 0
      show_description    if element.selectedSegmentIndex == 1
    end
  end
end