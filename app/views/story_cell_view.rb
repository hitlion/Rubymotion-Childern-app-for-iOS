class StoryCellView < UIView

  def initStoryCellViewWithFrame(frame, story: story)
    initWithFrame(frame)

    self.backgroundColor = UIColor.yellowColor

    image = UIImageView.alloc.initWithFrame(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
    image.image = UIImage.imageWithData(story.asset_data(story.document.thumbnail))

    layer = UIImageView.alloc.initWithFrame(CGRectMake(0, 0, 0.75 * self.frame.size.width, 0.33 * self.frame.size.height ))
    layer.image = UIImage.imageNamed("cell_layer")

    label = UILabel.alloc.initWithFrame(CGRectMake(0, 0, layer.frame.size.width, 0.5 * layer.frame.size.height))
    label.text = story.document.set_name
    label.textColor = UIColor.blackColor
    label.font = UIFont.fontWithName("Enriqueta-Bold", size:30)
    label.textAlignment = UITextAlignmentCenter

    left_button = UIButton.alloc.initWithFrame(CGRectMake(0.15 * layer.frame.size.width,0.6 * layer.frame.size.height,
                                                          0.3 * layer.frame.size.width, 0.3 * layer.frame.size.height))
    left_button.setBackgroundImage(UIImage.imageNamed("button_grey.png"), forState:UIControlStateNormal)
    left_button.setTitle("Mehr", forState: UIControlStateNormal)
    left_button.addTarget(self, action: "cell_left_button_pressed:", forControlEvents: UIControlEventTouchUpInside)
    right_button = UIButton.alloc.initWithFrame(CGRectMake(0.55 * layer.frame.size.width,0.6 * layer.frame.size.height,
                                                           0.3 * layer.frame.size.width, 0.3 * layer.frame.size.height))
    right_button.setBackgroundImage(UIImage.imageNamed("button_orange.png"), forState:UIControlStateNormal)
    right_button.setTitle("Spielen", forState: UIControlStateNormal)
    right_button.addTarget(self, action: "play_story:", forControlEvents: UIControlEventTouchUpInside)

    selectedStoryMarker = UIImageView.alloc.initWithFrame(CGRectMake(CGRectGetMidX(self.bounds)- 0.05 *  self.frame.size.width,
                                                                     self.frame.size.height - 0.05 * self.frame.size.width,
                                                                     0.1 * self.frame.size.width, 0.05 * self.frame.size.width))

    selectedStoryMarker.image = UIImage.imageNamed("Marker.png")

    self.addSubview(image)
    self.addSubview(layer)
    self.addSubview(label)
    self.addSubview(left_button)
    self.addSubview(right_button)
    self.addSubview(selectedStoryMarker)

    self
  end

  def play_story(button)
    cell  = button.superview.superview.superview
    path = @story_collection_view.indexPathForCell(cell)
    story = @story_list[path.row]

    StartScreen.next_story = story
    StartScreen.next_screen = :story_player
    StartScreen.last_screen = :parent_menu
    rmq.screen.open_root_screen(StartScreen)
  end

  def cell_left_button_pressed(button)

    cell  = button.superview.superview.superview
    path = @story_collection_view.indexPathForCell(cell)
    story = @story_list[path.row]

    if(@more_is_open)
      less(story)
      button.setTitle("Mehr", forState: UIControlStateNormal)
    else
      more(story)
      button.setTitle("Weniger", forState: UIControlStateNormal)
    end
  end

  def more (story)
    @sub_header.text = "Erstellte Level"
    @more_is_open = true
    @level_view.hidden = false
    @tips_view.hidden = true
  end

  def less (story)
    @sub_header.text = "Tipps und Tricks"
    @more_is_open = false
    @level_view.hidden = true
    @tips_view.hidden = false
  end

end