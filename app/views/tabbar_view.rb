class TabbarView < UIView

  attr_reader :delegate

  ##
  # UI elements position constants
  # This values are the factor, that is multiplied with self.frame.size.width
  # and defines the x coordinate for the element
  PosXButton1    = 0.35
  PosXButton2    = 0.465
  PosXButton3    = 0.60

  ##
  # other constants
  ElementHeight = 0.8
  SpaceHeight   = 0.1


  def init_with_frame(frame, delegate: delegate)
    self.initWithFrame(frame)

    @delegate = delegate

    build_view

    self
  end

  ##
  # build the whole view
  def build_view
    self.backgroundColor = rmq.color.babbo_bar_grey

    ####
    # Define horizontal line
    frame = CGRectMake(0.0 * self.frame.size.width, 0.0 * self.frame.size.height,
                       1.0 * self.frame.size.width, 1)
    line = UIView.alloc.initWithFrame(frame)
    line.backgroundColor = rmq.color.babbo_line_grey
    self.addSubview(line)

    ####
    # Define first button
    frame = CGRectMake(PosXButton1 * self.frame.size.width, SpaceHeight *  self.frame.size.height,
                       ElementHeight * self.frame.size.height, ElementHeight * self.frame.size.height)
    button1 = add_button_element_with_image(UIImage.imageNamed("icon_button_books.png"), displayName: "Stories",
                                            frame: frame, action: "button_pressed:")
    button1.tag = 1
    self.addSubview(button1)

    ####
    # Define second button
    frame = CGRectMake(PosXButton2 * self.frame.size.width, SpaceHeight *  self.frame.size.height,
                       ElementHeight * self.frame.size.height, ElementHeight * self.frame.size.height)
    button2 = add_button_element_with_image(UIImage.imageNamed("icon_button_videos.png"), displayName: "Videos",
                                            frame: frame, action: "button_pressed:")
    button2.tag = 2
    self.addSubview(button2)

    ####
    # Define third button
    frame = CGRectMake(PosXButton3 * self.frame.size.width, SpaceHeight *  self.frame.size.height,
                       ElementHeight * self.frame.size.height, ElementHeight * self.frame.size.height)
    button3 = add_button_element_with_image(UIImage.imageNamed("icon_button_games.png"), displayName: "Spiele",
                                            frame: frame, action: "button_pressed:")
    button3.tag = 3
    self.addSubview(button3)

  end

  ##
  # Adds a element with a button and a label under this button
  # @param image Image for the button
  # @param name Text for the label
  # @param frame [CGRect] The frame for the button
  # @param action [String] The delegate action fot the button
  def add_button_element_with_image(image, displayName: name, frame: frame, action: action)
    element =  UIView.alloc.initWithFrame(frame)

    button = UIButton.alloc.initWithFrame(CGRectMake(0.25 * element.frame.size.width,
                                                     0.05 * element.frame.size.height,
                                                     0.50 * element.frame.size.width,
                                                     0.50 * element.frame.size.height))
    button.setImage(image, forState:UIControlStateNormal)

    button.addTarget(self, action: action, forControlEvents: UIControlEventTouchDown)

    label = UILabel.alloc.initWithFrame(CGRectMake(0,
                                                   0.65 * element.frame.size.height,
                                                   element.frame.size.width,
                                                   0.3 * element.frame.size.height))
    label.text = name
    label.font = UIFont.fontWithName("Enriqueta-Regular", size:13)
    label.textAlignment = UITextAlignmentCenter

    element.addSubview button
    element.addSubview label

    element
  end

  ##
  # Called if the user pressed on of the navbars buttons
  # than call the delegate method with the params self (this navbar) and the pressed button element
  # @param source [UIButton] the pressed cell's button the whole cell is the button
  def button_pressed (source)
    @delegate.tabbarView(self, buttonPressed: source) if @delegate.respond_to? 'tabbarView:buttonPressed:'
  end
end