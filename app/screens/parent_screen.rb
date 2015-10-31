class ParentScreen < PM::Screen

  title "Elternmenue"

  LEFT_LABEL_X_POS = 0.02
  LEFT_BUTTON_X_POS = 0.5
  MIDDLE_BUTTON_X_POS = 0.6
  RIGHT_BUTTON_X_POS = 0.7
  NAVBAR_ELEMENT_HEIGHT = 0.7



  def will_appear

    navbar_heigth = 0.1 * device.screen_height
    navbar_width = device.screen_width
    navbar_element_height = NAVBAR_ELEMENT_HEIGHT * navbar_heigth
    button_width = navbar_element_height

    @own_nav_bar = UIView.alloc.initWithFrame(CGRectMake(0 ,0, navbar_width, navbar_heigth))
    @own_nav_bar.backgroundColor = UIColor.colorWithRed(247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha:1.0)

    add @own_nav_bar

    @left_label = UILabel.alloc.initWithFrame(CGRectMake(0.02 * navbar_width,0.3 * navbar_heigth,
                                                         0.5 * navbar_width,navbar_element_height))
    @left_label.text = "Alle Spiele"
    @left_label.font = UIFont.fontWithName("Enriqueta-Bold", size:30)

    @own_nav_bar.addSubview @left_label

    add_button_element_with_image(UIImage.imageNamed("KidsMenue.png"),
                                  displayName: "Spielplatz",
                                  position: CGPointMake(0.5 * navbar_width, 0.3 * navbar_heigth),
                                  size: CGSizeMake(button_width, navbar_element_height))

    add_button_element_with_image(UIImage.imageNamed("Shop.png"),
                                                 displayName: "Shop",
                                                 position: CGPointMake(0.6 * navbar_width, 0.3 * navbar_heigth),
                                                 size: CGSizeMake(button_width, navbar_element_height))

    add_button_element_with_image(UIImage.imageNamed("Optionen.png"),
                                                 displayName: "Optionen",
                                                 position: CGPointMake(0.7 * navbar_width, 0.3 * navbar_heigth),
                                                 size: CGSizeMake(button_width, navbar_element_height))

    add_seach_bar_at_position(CGPointMake(0.8 * navbar_width,0.3 * navbar_heigth),
                              size: CGSizeMake(0.2 * navbar_width, navbar_element_height),
                              placeholder: "Suchen")

  end

  def will_disappear

  end

  def go_to_shop

  end

  def add_seach_bar_at_position(pos, size: size, placeholder: ph)
    search_bar = UISearchBar.alloc.initWithFrame(CGRectMake(pos.x,pos.y, size.width, size.height))
    search_bar.placeholder = ph
    search_bar.backgroundImage = UIImage.alloc.init

    textField = UITextField.appearanceWhenContainedIn(UISearchBar,nil)
    textField.backgroundColor = UIColor.lightGrayColor

    @own_nav_bar.addSubview search_bar
  end

  def add_button_element_with_image(image, displayName: name, position: pos, size:size)
    element =  UIView.alloc.initWithFrame(CGRectMake(pos.x , pos.y, size.height, size.width))

    button = UIButton.alloc.initWithFrame(CGRectMake(0.25* element.frame.size.width,
                                                     0 * element.frame.size.height,
                                                     0.5 * element.frame.size.width,
                                                     0.5 * element.frame.size.height))
    button.setImage(image, forState:UIControlStateNormal)

    label = UILabel.alloc.initWithFrame(CGRectMake(0,
                                                   0.6 * element.frame.size.height,
                                                   element.frame.size.width,
                                                   0.3 * element.frame.size.height))
    label.text = name
    label.font = UIFont.fontWithName("Enriqueta-Regular", size:11)
    label.textAlignment = UITextAlignmentCenter

    element.addSubview button
    element.addSubview label

    @own_nav_bar.addSubview element
  end
end
