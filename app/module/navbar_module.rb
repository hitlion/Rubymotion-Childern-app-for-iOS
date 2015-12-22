module NavbarModule

  attr_reader :pos_x_back_button, :pos_x_label, :pos_x_button_1,
              :pos_x_button_2, :pos_x_button_3, :pos_x_searchbar,
              :element_size, :icon_size, :label_width, :searchbar_width,
              :title_text, :delegate

  ##
  # Override this method to re-design the navbar methods
  # Copy the following parts and change the standard values
  # If this mehtods inst used than the layout used this standard values
  # @init = true is important, without this the values will be overriden with the
  # standard values again
  # @pos_x_back_button  = 0.00
  # @pos_x_label        = 0.10
  # @pos_x_button_1     = 0.55
  # @pos_x_button_2     = 0.65
  # @pos_x_button_3     = 0.75
  # @pos_x_searchbar    = 0.85
  #
  # @element_size       = 64
  # @icon_size          = 32
  #
  # @label_width        = 0.4
  # @searchbar_width    = 0.15
  #
  # @title_text         = titleText
  # @delegate           = delegate
  # @init = true
  def init_navbar_with_delegate(delegate, titleText: titleText)
    @pos_x_back_button  = 0.00
    @pos_x_label        = 0.10
    @pos_x_button_1     = 0.55
    @pos_x_button_2     = 0.65
    @pos_x_button_3     = 0.75
    @pos_x_searchbar    = 0.85

    @element_size       = 64
    @icon_size          = 32

    @label_width        = 0.4
    @searchbar_width    = 0.15

    @title_text         = titleText
    @delegate           = delegate

    @init = true
  end

  ##
  # build the whole view
  def build_view

    init_navbar_with_delegate(self, titleText: "No Text") if @init.nil? || !@init

    self.backgroundColor = rmq.color.babbo_bar_grey

    ####
    # Define the elements y position
    y_pos_elements = (self.frame.size.height - @element_size) / 2.0
    y_pos_elements = 0 if y_pos_elements < 0

    ####
    # Define the back button
    frame = CGRectMake(@pos_x_back_button * self.frame.size.width, y_pos_elements,
                       @element_size, @element_size)
    @leftButton = add_button_element_with_image(UIImage.imageNamed("icons/arrow_left.png"), displayName: "Zurück",
                                            frame: frame, action: "button_pressed:", id: 0)
    @leftButton.hidden = true
    self.addSubview(@leftButton)

    ####
    # Define title label
    frame = CGRectMake(@pos_x_label * self.frame.size.width, y_pos_elements,
                       @label_width * self.frame.size.width, @element_size)
    @title_label = UILabel.alloc.initWithFrame(frame)
    @title_label.text = @title_text
    @title_label.font = UIFont.fontWithName(Util.get_font_standard(:bold), size: Util.get_font_size(:xl))
    self.addSubview(@title_label)

    ####
    # Define the first button
    frame = CGRectMake(@pos_x_button_1 * self.frame.size.width, y_pos_elements,
                       @element_size, @element_size)
    button1 = add_button_element_with_image(UIImage.imageNamed("icons/playground.png"), displayName: "Spielplatz",
                                            frame: frame, action: "button_pressed:", id: 1)
    self.addSubview(button1)

    ####
    # Define second button
    frame = CGRectMake(@pos_x_button_2 * self.frame.size.width, y_pos_elements,
                       @element_size, @element_size)
    button2 = add_button_element_with_image(UIImage.imageNamed("icons/shop.png"), displayName: "Shop",
                                            frame: frame, action: "button_pressed:", id: 2)
    self.addSubview(button2)

    ####
    # Define third button
    frame = CGRectMake(@pos_x_button_3 * self.frame.size.width, y_pos_elements,
                       @element_size, @element_size)
    image = UIImage.imageNamed("icons/option.png").imageWithRenderingMode(UIImageRenderingModeAlwaysTemplate)
    button3 = add_button_element_with_image(image, displayName: "Optionen", frame: frame, action: "button_pressed:", id: 3)
    self.addSubview(button3)

    ####
    # Define searchbar
    frame = CGRectMake(@pos_x_searchbar * self.frame.size.width, y_pos_elements,
                       @searchbar_width * self.frame.size.width, @element_size)
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
    button.frame = CGRectMake(0.25 * element.frame.size.width, 0.10 * element.frame.size.height,
                              @icon_size, @icon_size)
    button.setImage(image, forState:UIControlStateNormal)

    button.addTarget(self, action: action, forControlEvents: UIControlEventTouchDown)
    button.tag = id
    button.tintColor = rmq.color.babbo_button_grey

    label = UILabel.alloc.initWithFrame(CGRectMake(0, 0.65 * element.frame.size.height,
                                                   element.frame.size.width, 0.35 * element.frame.size.height))
    label.text = name
    label.font = UIFont.fontWithName(Util.get_font_standard(:regular), size: Util.get_font_size(:small))
    label.textAlignment = UITextAlignmentCenter

    element.addSubview button
    element.addSubview label

    return element
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