class SmartphoneTabbarView < UIView

  attr_reader :delegate

  ##
  # UI elements position constants
  # This values are the factor, that is multiplied with self.frame.size.width
  # and defines the x coordinate for the element
  PosXButton1    = 0.25
  PosXButton2    = 0.475
  PosXButton3    = 0.70

  ##
  # other constants
  ButtonHeight     = 32
  ButtonIconHeight = 32

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

    gap = (self.frame.size.height - ButtonHeight) / 2.0
    ####
    # Define horizontal line
    frame = CGRectMake(0.0 * self.frame.size.width, 0.0 * self.frame.size.height,
                       1.0 * self.frame.size.width, 1)
    line = UIView.alloc.initWithFrame(frame)
    line.backgroundColor = rmq.color.babbo_line_grey
    self.addSubview(line)

    ####
    # Define first button
    frame = CGRectMake(PosXButton1 * self.frame.size.width, gap, ButtonHeight, ButtonHeight)
    button1 = add_button_element_with_image(UIImage.imageNamed("icons/book.png"), displayName: "Stories",
                                            frame: frame, action: "button_pressed:", id: 1)
    self.addSubview(button1)

    ####
    # Define second button
    frame = CGRectMake(PosXButton2 * self.frame.size.width, gap, ButtonHeight, ButtonHeight)
    button2 = add_button_element_with_image(UIImage.imageNamed("icons/video.png"), displayName: "Videos",
                                            frame: frame, action: "button_pressed:", id: 2)
    self.addSubview(button2)

    ####
    # Define third button
    frame = CGRectMake(PosXButton3 * self.frame.size.width, gap, ButtonHeight, ButtonHeight)
    button3 = add_button_element_with_image(UIImage.imageNamed("icons/games.png"), displayName: "Spiele",
                                            frame: frame, action: "button_pressed:", id: 3)
    self.addSubview(button3)

  end

  ##
  # Adds a element with a button and a label under this button
  # @param image Image for the button
  # @param name Text for the label
  # @param frame [CGRect] The frame for the button
  # @param action [String] The delegate action fot the button
  # @param id [Integer] A unique ID (in this class) to identify the button later
  def add_button_element_with_image(image, displayName: name, frame: frame, action: action, id: id)
    element =  UIView.alloc.initWithFrame(frame)

    button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    button.frame = CGRectMake(0.00 * element.frame.size.width, 0.00 * element.frame.size.height,
                              ButtonIconHeight, ButtonIconHeight)
    button.setImage(image, forState:UIControlStateNormal)
    button.addTarget(self, action: action, forControlEvents: UIControlEventTouchDown)
    button.tag = id
    button.backgroundColor = UIColor.clearColor
    button.tintColor = rmq.color.babbo_button_grey

    element.addSubview button

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