module TabbarModule
  attr_reader :pos_x_button_1, :pos_x_button_2, :pos_x_button_3,
              :element_size, :icon_size, :delegate

  ##
  # Override this method to re-design the navbar methods
  # Copy the following parts and change the standard values
  # If this methods inst used than the layout used this standard values
  # @init = true is important, without this the values will be overridden with the
  # standard values again
  #
  # @delegate           = delegate
  # @init = true
  def init_navbar_with_delegate(delegate)
    @pos_x_button_1     = 0.33
    @pos_x_button_2     = 0.47
    @pos_x_button_3     = 0.61

    @element_size       = 64
    @icon_size          = 32

    @delegate           = delegate

    @init = true
  end

  ##
  # build the whole view
  def build_view
    init_navbar_with_delegate(self) if @init.nil? || !@init

    self.backgroundColor = rmq.color.babbo_bar_grey

    ####
    # Define the elements y position
    y_pos_elements = (self.frame.size.height - @element_size) / 2.0
    y_pos_elements = 0 if y_pos_elements < 0
    ####
    # Define horizontal line
    frame = CGRectMake(0.0 * self.frame.size.width, 0.0 * self.frame.size.height,
                       1.0 * self.frame.size.width, 1)
    line = UIView.alloc.initWithFrame(frame)
    line.backgroundColor = rmq.color.babbo_line_grey
    self.addSubview(line)

    ####
    # Define first button
    frame = CGRectMake(@pos_x_button_1 * self.frame.size.width, y_pos_elements, @element_size, @element_size)
    button1 = add_button_element_with_image(UIImage.imageNamed("icons/book.png"), displayName: "Stories",
                                            frame: frame, action: "button_pressed:", id: 1)
    self.addSubview(button1)

    ####
    # Define second button
    frame = CGRectMake(@pos_x_button_2 * self.frame.size.width, y_pos_elements, @element_size, @element_size)
    button2 = add_button_element_with_image(UIImage.imageNamed("icons/video.png"), displayName: "Videos",
                                            frame: frame, action: "button_pressed:", id: 2)
    self.addSubview(button2)

    ####
    # Define third button
    frame = CGRectMake(@pos_x_button_3 * self.frame.size.width, y_pos_elements, @element_size, @element_size)
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
    button.frame = CGRectMake(0.25 * element.frame.size.width, 0.10 * element.frame.size.height,
                              @icon_size, @icon_size)
    button.setImage(image, forState:UIControlStateNormal)
    button.addTarget(self, action: action, forControlEvents: UIControlEventTouchDown)
    button.tag = id
    button.backgroundColor = UIColor.clearColor
    button.tintColor = rmq.color.babbo_button_grey

    label = UILabel.alloc.initWithFrame(CGRectMake(0, 0.65 * element.frame.size.height,
                                                   element.frame.size.width, 0.35 * element.frame.size.height))
    label.text = name
    label.font = UIFont.fontWithName(Util.get_font_standard(:regular), size: Util.get_font_size(:small))
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