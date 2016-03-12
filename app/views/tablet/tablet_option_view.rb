class TabletOptionView < UIView

  attr_reader :delegate

  def init_with_frame(frame, delegate: delegate)
    self.initWithFrame(frame)

    @delegate = delegate

    build_view

    self
  end

  def build_view
    frame = CGRectMake(0,0, self.frame.size.width, self.frame.size.height)
    background = UIImageView.alloc.initWithFrame(frame)
    background.image = UIImage.imageNamed("background_grey_trans.png")

    @options_table = UIImageView.alloc.initWithFrame(CGRectMake(0.75 * self.frame.size.width, 0,
                                                               0.25 * self.frame.size.width, self.frame.size.height))
    @options_table.image = UIImage.imageNamed("tablet_background_option.png")

    parent_image = UIImageView.alloc.initWithFrame(CGRectMake(0.1 * @options_table.frame.size.width,
                                                              (1.0/32.0) * @options_table.frame.size.height,
                                                              0.8 * @options_table.frame.size.width,
                                                              (9.0/32.0) * @options_table.frame.size.height))
    parent_image.backgroundColor = UIColor.clearColor
    parent_image.image = UIImage.imageNamed("avatar_parent.png")

    parent_name = UILabel.alloc.initWithFrame(CGRectMake(0,
                                                         (10/32.0) * @options_table.frame.size.height,
                                                         @options_table.frame.size.width,
                                                         (1.0/32.0) * @options_table.frame.size.height))
    parent_name.text = "Username"
    parent_name.font = UIFont.fontWithName("Enriqueta-Regular", size:20)
    parent_name.textColor = rmq.color.babbo_orange
    parent_name.textAlignment = UITextAlignmentCenter

    table = UIView.alloc.initWithFrame(CGRectMake(0,
                                                  (12.0/32.0) * @options_table.frame.size.height,
                                                  @options_table.frame.size.width,
                                                  (10.0/32.0) * @options_table.frame.size.height))
    table.backgroundColor = UIColor.clearColor

    tableButton_1 = create_option_buttons(UIImage.imageNamed("icon_close_black.png"),
                                          displayName: "Gutscheine",
                                          frame:CGRectMake(0, 0,
                                                           table.frame.size.width, 0.25 * table.frame.size.height),
                                          action: "action")
    tableButton_2 = create_option_buttons(UIImage.imageNamed("icon_close_black.png"),
                                          displayName: "Unterstützer",
                                          frame:CGRectMake(0, 0.25 * table.frame.size.height,
                                                           table.frame.size.width, 0.25 * table.frame.size.height),
                                          action: "action")
    tableButton_3 = create_option_buttons(UIImage.imageNamed("icon_close_black.png"),
                                          displayName: "Impressum",
                                          frame:CGRectMake(0, 0.5 * table.frame.size.height,
                                                           table.frame.size.width, 0.25 * table.frame.size.height),
                                          action: "action")
    tableButton_4 = create_option_buttons(UIImage.imageNamed("icon_close_black.png"),
                                          displayName: "weiterer Eintrag",
                                          frame:CGRectMake(0, 0.75 * table.frame.size.height,
                                                           table.frame.size.width, 0.25 * table.frame.size.height),
                                          action: "action")

    lineBottom = UIView.alloc.initWithFrame(CGRectMake(0 * tableButton_4.frame.size.width,
                                                       tableButton_4.frame.size.height - 1,
                                                       tableButton_4.frame.size.width, 1))
    lineBottom.backgroundColor = rmq.color.babbo_line_grey
    tableButton_4.addSubview(lineBottom)

    table.addSubview(tableButton_1)
    table.addSubview(tableButton_2)
    table.addSubview(tableButton_3)
    table.addSubview(tableButton_4)

    logo = UIImageView.alloc.initWithFrame(CGRectMake(0.1 * @options_table.frame.size.width,
                                                      (22.0/32.0) * @options_table.frame.size.height,
                                                      0.8 * @options_table.frame.size.width,
                                                      (9.0/32.0) * @options_table.frame.size.height))
    logo.image = UIImage.imageNamed("Logo_Orange.png")

    version_number = UILabel.alloc.initWithFrame(CGRectMake(0,
                                                            (31.0/32.0) * @options_table.frame.size.height,
                                                            @options_table.frame.size.width,
                                                            (1.0/32.0) * @options_table.frame.size.height))
    version_number.text = app.version
    version_number.font = UIFont.fontWithName("Enriqueta-Regular", size:15)
    version_number.textAlignment = UITextAlignmentCenter

    @options_table.addSubview(parent_image)
    @options_table.addSubview(parent_name)
    @options_table.addSubview(table)
    @options_table.addSubview(logo)
    @options_table.addSubview(version_number)

    self.hidden = true
    self.addSubview(background)
    self.addSubview(@options_table)
  end

  def create_option_buttons(image, displayName: name, frame:frame, action: action)

    button =  UIButton.alloc.initWithFrame(frame)

    view = UIView.alloc.initWithFrame(button.bounds)

    imageView = UIImageView.alloc.initWithFrame(CGRectMake(0.1 * view.frame.size.width,
                                                           0.25 * view.frame.size.height,
                                                           0.1  * view.frame.size.width,
                                                           0.5 * view.frame.size.height))
    imageView.image = image

    labelView = UILabel.alloc.initWithFrame(CGRectMake(0.3 * view.frame.size.width,
                                                       0.05 * view.frame.size.height,
                                                       0.7  * view.frame.size.width,
                                                       0.9 * view.frame.size.height))

    labelView.text = name
    labelView.font = UIFont.fontWithName("Enriqueta-Regular", size:18)
    labelView.textAlignment = UITextAlignmentLeft

    lineTop = UIView.alloc.initWithFrame(CGRectMake(0 * view.frame.size.width,
                                                    0 * view.frame.size.height,
                                                    view.frame.size.width, 1))
    lineTop.backgroundColor = rmq.color.babbo_line_grey

    view.addSubview(imageView)
    view.addSubview(labelView)
    view.addSubview(lineTop)

    button.addSubview(view)

    button
  end

  ##
  # Called when the touch ended
  def touchesEnded(touches, withEvent: event)
    super
    close_options if (!CGRectContainsPoint(@options_table.bounds, touches.anyObject.locationInView(@options_table)))
  end

  def close_options
    self.hidden = true
    @delegate.tabletOptionViewClosed(self) if @delegate.respond_to? 'tabletOptionViewClosed:'
  end

end