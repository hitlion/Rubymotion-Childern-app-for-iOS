class TabletNavbarView < UIView

  attr_reader :title_text, :delegate

  ##
  # UI elements position constants
  # This values are the factor, that is multiplied with self.frame.size.width
  # and defines the x coordinate for the element
  PosXLeftButton = 0.00
  PosXLabel      = 0.05
  PosXButton1    = 0.55
  PosXButton2    = 0.65
  PosXButton3    = 0.75
  PosXSearchBar  = 0.85
  PosYSearchbar  = 0.175
  PosYLabel      = 0.15

  ##
  # other constants
  HeightStatusbar = 0.15
  HeightNavbar    = 0.85
  ButtonWidth     = 0.075
  LabelWidth      = 0.4
  SearchbarWidth  = 0.15

  def init_with_frame(frame, titleText: titleText, delegate: delegate)
    self.initWithFrame(frame)

    @titleText = titleText
    @delegate  = delegate
    build_view

    self
  end

  ##
  # build the whole view
  def build_view
    self.backgroundColor = rmq.color.babbo_bar_grey

    ####
    # Define the left button
    frame = CGRectMake(PosXLeftButton * self.frame.size.width, HeightStatusbar * self.frame.size.height,
                       ButtonWidth * self.frame.size.width, HeightNavbar * self.frame.size.height)
    @leftButton = UIButton.alloc.initWithFrame(frame)
    @leftButton.setImage(UIImage.imageNamed("previous.png"), forState:UIControlStateNormal)
    @leftButton.addTarget(self, action: "button_pressed:", forControlEvents: UIControlEventTouchUpInside)
    @leftButton.tag = 0
    self.addSubview(@leftButton)

    ####
    # Define title label
    frame = CGRectMake(PosXLabel * self.frame.size.width, PosYLabel * self.frame.size.height,
                       LabelWidth * self.frame.size.width, HeightNavbar * self.frame.size.height)
    title_label = UILabel.alloc.initWithFrame(frame)
    title_label.text = @titleText
    title_label.font = UIFont.fontWithName("Enriqueta-Bold", size:40)
    self.addSubview(title_label)

    ####
    # Define first button
    frame = CGRectMake(PosXButton1 * self.frame.size.width, HeightStatusbar *  self.frame.size.height,
                       ButtonWidth * self.frame.size.width, HeightNavbar * self.frame.size.height)
    button1 = add_button_element_with_image(UIImage.imageNamed("icon_button_playground.png"), displayName: "Spielplatz",
                                            frame: frame, action: "button_pressed:")
    button1.tag = 1
    self.addSubview(button1)

    ####
    # Define second button
    frame = CGRectMake(PosXButton2 * self.frame.size.width, HeightStatusbar *  self.frame.size.height,
                       ButtonWidth * self.frame.size.width, HeightNavbar * self.frame.size.height)
    button2 = add_button_element_with_image(UIImage.imageNamed("icon_button_shop.png"), displayName: "Shop",
                                                      frame: frame, action: "button_pressed:")
    button2.tag = 2
    self.addSubview(button2)

    ####
    # Define third button
    frame = CGRectMake(PosXButton3 * self.frame.size.width, HeightStatusbar *  self.frame.size.height,
                       ButtonWidth * self.frame.size.width, HeightNavbar * self.frame.size.height)
    button3 = add_button_element_with_image(UIImage.imageNamed("icon_button_options.png"), displayName: "Optionen",
                                                      frame: frame, action: "button_pressed:")
    button3.tag = 3
    self.addSubview(button3)

    ####
    # Define searchbar
    frame = CGRectMake(PosXSearchBar * self.frame.size.width, PosYSearchbar * self.frame.size.height,
                       SearchbarWidth * self.frame.size.width, 0.5 * HeightNavbar * self.frame.size.height)
    search_bar = add_seach_bar_with_frame(frame, placeholder: "Suchen")
    self.addSubview(search_bar)

    ####
    # Define navbars underline
    frame = CGRectMake(0.0 * self.frame.size.width, 1.0 * self.frame.size.height - 1,
                       1.0 * self.frame.size.width, 1)
    line = UIView.alloc.initWithFrame(frame)
    line.backgroundColor = rmq.color.babbo_line_grey
    self.addSubview(line)
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
  # Adds a search bar
  # @param frame [CGRect] The frame for the searchbar
  # @param placeholder [String] The placeholder string
  def add_seach_bar_with_frame(frame, placeholder: placeHolder)
    search_bar = UISearchBar.alloc.initWithFrame(frame)
    search_bar.placeholder = placeHolder
    search_bar.backgroundImage = UIImage.alloc.init
    search_bar.barTintColor = rmq.color.babbo_bar_grey
    search_bar.searchBarStyle = UISearchBarStyleMinimal

    textField = UITextField.appearanceWhenContainedIn(UISearchBar,nil)
    textField.backgroundColor = UIColor.whiteColor

    search_bar
  end

  ##
  # Called if the user pressed on of the navbars buttons
  # than call the delegate method with the params self (this navbar) and the pressed button element
  # @param source [UIButton] the pressed cell's button the whole cell is the button
  def button_pressed (source)
    @delegate.tabletNavBarView(self, buttonPressed: source) if @delegate.respond_to? 'tabletNavBarView:buttonPressed:'
  end

end