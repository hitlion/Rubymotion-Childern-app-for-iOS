class SmartphoneNavbarView < UIView

  attr_reader :title_text, :delegate

  ##
  # UI elements position constants
  # This values are the factor, that is multiplied with self.frame.size.width
  # and defines the x coordinate for the element
  PosXLeftButton = 0.00
  PosXLabel      = 0.4
  PosXButton1    = 0.7
  PosXButton2    = 0.8
  PosXButton3    = 0.9
  PosXSearchbar  = 0.00
  PosYSearchbar  = 0.25
  PosYLabel      = 0.1

  ##
  # other constants
  HeightStatusbar = 0.00
  HeightNavbar    = 0.85
  ButtonIconSize  = 32
  ButtonWidth     = 64
  LabelWidth      = 0.4
  SearchbarWidth  = 0.25

  def init_with_frame(frame, titleText: titleText, delegate: delegate)
    self.initWithFrame(frame)

    @title_text = titleText
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
                       ButtonWidth, ButtonWidth)
    @leftButton = UIButton.alloc.initWithFrame(frame)
    @leftButton.setImage(UIImage.imageNamed("previous.png"), forState:UIControlStateNormal)
    @leftButton.addTarget(self, action: "button_pressed:", forControlEvents: UIControlEventTouchUpInside)
    @leftButton.tag = 0
    @leftButton.hidden = true
    self.addSubview(@leftButton)

    ####
    # Define title label
    frame = CGRectMake(PosXLabel * self.frame.size.width, PosYLabel * self.frame.size.height,
                       LabelWidth * self.frame.size.width, HeightNavbar * self.frame.size.height)
    @title_label = UILabel.alloc.initWithFrame(frame)
    @title_label.text = @title_text
    @title_label.font = UIFont.fontWithName("Enriqueta-Bold", size:25)
    self.addSubview(@title_label)

    ####
    # Define first button
    frame = CGRectMake(PosXButton1 * self.frame.size.width, HeightStatusbar *  self.frame.size.height,
                       ButtonWidth, ButtonWidth)
    button1 = add_button_element_with_image(UIImage.imageNamed("icon_button_playground.png"), displayName: "Spielplatz",
                                            frame: frame, action: "button_pressed:", id: 1)
    self.addSubview(button1)

    ####
    # Define second button
    frame = CGRectMake(PosXButton2 * self.frame.size.width, HeightStatusbar *  self.frame.size.height,
                       ButtonWidth, ButtonWidth)
    button2 = add_button_element_with_image(UIImage.imageNamed("icon_button_shop.png"), displayName: "Shop",
                                                      frame: frame, action: "button_pressed:", id: 2)
    self.addSubview(button2)

    ####
    # Define third button
    frame = CGRectMake(PosXButton3 * self.frame.size.width, HeightStatusbar *  self.frame.size.height,
                       ButtonWidth, ButtonWidth)
    image = UIImage.imageNamed("icon_button_options.png").imageWithRenderingMode(UIImageRenderingModeAlwaysTemplate)
    button3 = add_button_element_with_image(image, displayName: "Optionen", frame: frame, action: "button_pressed:", id: 3)
    self.addSubview(button3)

    ####
    # Define searchbar
    frame = CGRectMake(PosXSearchbar * self.frame.size.width, PosYSearchbar * self.frame.size.height,
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
  def add_button_element_with_image(image, displayName: name, frame: frame, action: action,  id: id)
    element =  UIView.alloc.initWithFrame(frame)

    button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    button.frame = CGRectMake(0.25 * element.frame.size.width, 0.05 * element.frame.size.height,
                              ButtonIconSize, ButtonIconSize)
    button.setImage(image, forState:UIControlStateNormal)

    button.addTarget(self, action: action, forControlEvents: UIControlEventTouchDown)
    button.tag = id
    button.tintColor = rmq.color.babbo_button_grey

    label = UILabel.alloc.initWithFrame(CGRectMake(0,
                                                   0.55 * element.frame.size.height,
                                                   element.frame.size.width,
                                                   0.3 * element.frame.size.height))
    label.text = name
    label.font = UIFont.fontWithName("Enriqueta-Regular", size:10)
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
    search_bar.searchBarStyle = UISearchBarStyleDefault

    textField = UITextField.appearanceWhenContainedIn(UISearchBar,nil)
    textField.backgroundColor = UIColor.whiteColor

    search_bar
  end

  ##
  # Called if the user pressed on of the navbars buttons
  # than call the delegate method with the params self (this navbar) and the pressed button element
  # @param source [UIButton] the pressed cell's button the whole cell is the button
  def button_pressed (source)
    @delegate.tabletNavbarView(self, buttonPressed: source) if @delegate.respond_to? 'tabletNavbarView:buttonPressed:'

    if(source.tintColor != rmq.color.babbo_button_orange)
      source.tintColor = rmq.color.babbo_button_orange
      if(!@last_selected_button.nil? && @last_selected_button != source )
        @last_selected_button.tintColor = rmq.color.babbo_button_grey
      end
    else
      if(source.tag == 3)
        source.tintColor = rmq.color.babbo_button_grey
      end
    end

    @last_selected_button = source

  end

  def hide_back_button
    @leftButton.hidden = true
  end

  def show_back_button
    @leftButton.hidden = false
  end

  def set_title_text(text)
    @title_label.text = text
    @title_text = text
  end

  def set_last_selected_button_inactive
    return if (@last_selected_button.nil?)
    @last_selected_button.tintColor = rmq.color.babbo_button_grey
    @last_selected_button = nil
  end

end