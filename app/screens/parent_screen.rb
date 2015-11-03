class ParentScreen < PM::Screen

  title "Elternmenue"

  LEFT_LABEL_X_POS      = 0.02  # * navbar width
  LEFT_BUTTON_X_POS     = 0.5   # * navbar width
  MIDDLE_BUTTON_X_POS   = 0.6   # * navbar width
  RIGHT_BUTTON_X_POS    = 0.7   # * navbar width
  NAVBAR_ELEMENT_HEIGHT = 0.7   # * navbar height
  NAVBAR_HEIGHT         = 0.1   # * screen_height
  STORY_VIEW_HEIGHT     = 0.4   # * screen_height
  LEVEL_VIEW_HEIGHT     = 0.4   # * screen_height

  CellIdentifier = 'MyCell'

  def on_load
    lp "test Robert"
  end

  def will_appear

    @parentmenu = UIView.alloc.initWithFrame(CGRectMake(0 ,0, device.screen_width, device.screen_height))
    @parentmenu.backgroundColor = UIColor.colorWithRed(255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha:1.0)

    add @parentmenu

    add_nav_bar

    add_story_scroll_view

    add_level_scroll_view
  end

  def will_disappear

  end

  def go_to_shop

  end

  def add_nav_bar
    navbar_heigth = NAVBAR_HEIGHT * device.screen_height
    navbar_width = device.screen_width
    navbar_element_height = NAVBAR_ELEMENT_HEIGHT * navbar_heigth
    button_width = navbar_element_height

    @own_nav_bar = UIView.alloc.initWithFrame(CGRectMake(0 ,0, navbar_width, navbar_heigth))
    @own_nav_bar.backgroundColor = UIColor.colorWithRed(247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha:1.0)

    @parentmenu.addSubview @own_nav_bar

    @left_label = UILabel.alloc.initWithFrame(CGRectMake(0.02 * navbar_width,0.3 * navbar_heigth,
                                                         0.5 * navbar_width,navbar_element_height))
    @left_label.text = "Alle Spiele"
    @left_label.font = UIFont.fontWithName("Enriqueta-Bold", size:30)

    @own_nav_bar.addSubview @left_label

    @goto_kids_button = add_button_element_with_image(UIImage.imageNamed("KidsMenue.png"),
                                  displayName: "Spielplatz",
                                  position: CGPointMake(0.5 * navbar_width, 0.3 * navbar_heigth),
                                  size: CGSizeMake(button_width, navbar_element_height),
                                  action: "goto_kids_menu")

    @goto_shop_button = add_button_element_with_image(UIImage.imageNamed("Shop.png"),
                                  displayName: "Shop",
                                  position: CGPointMake(0.6 * navbar_width, 0.3 * navbar_heigth),
                                  size: CGSizeMake(button_width, navbar_element_height),
                                  action: "goto_shop")

    @goto_option_button = add_button_element_with_image(UIImage.imageNamed("Optionen.png"),
                                  displayName: "Optionen",
                                  position: CGPointMake(0.7 * navbar_width, 0.3 * navbar_heigth),
                                  size: CGSizeMake(button_width, navbar_element_height),
                                  action: "goto_options")

    @search_bar = add_seach_bar_at_position(CGPointMake(0.8 * navbar_width,0.3 * navbar_heigth),
                              size: CGSizeMake(0.2 * navbar_width, navbar_element_height),
                              placeholder: "Suchen")

    @own_nav_bar.addSubview @goto_kids_button
    @own_nav_bar.addSubview @goto_shop_button
    @own_nav_bar.addSubview @goto_option_button
    @own_nav_bar.addSubview @search_bar

     end

  def add_seach_bar_at_position(pos, size: size, placeholder: ph)
    search_bar = UISearchBar.alloc.initWithFrame(CGRectMake(pos.x, pos.y, size.width, size.height))
    search_bar.placeholder = ph
    search_bar.backgroundImage = UIImage.alloc.init

    textField = UITextField.appearanceWhenContainedIn(UISearchBar,nil)
    textField.backgroundColor = UIColor.lightGrayColor

    search_bar
  end


  ##
  # Adds a element with a button and a label under this button
  #
  # @param image Image for the button
  # @param name Text for the label
  # @param pos The position of the button
  # @param size The size of the button
  #
  def add_button_element_with_image(image, displayName: name, position: pos, size:size, action: action)
    element =  UIView.alloc.initWithFrame(CGRectMake(pos.x , pos.y, size.height, size.width))

    button = UIButton.alloc.initWithFrame(CGRectMake(0.25* element.frame.size.width,
                                                     0 * element.frame.size.height,
                                                     0.5 * element.frame.size.width,
                                                     0.5 * element.frame.size.height))
    button.setImage(image, forState:UIControlStateNormal)

    button.addTarget(self, action: action, forControlEvents: UIControlEventTouchUpInside)

    label = UILabel.alloc.initWithFrame(CGRectMake(0,
                                                   0.6 * element.frame.size.height,
                                                   element.frame.size.width,
                                                   0.3 * element.frame.size.height))
    label.text = name
    label.font = UIFont.fontWithName("Enriqueta-Regular", size:11)
    label.textAlignment = UITextAlignmentCenter

    element.addSubview button
    element.addSubview label

    element
  end

  def add_story_scroll_view



  end

  def goto_kids_menu
    StartScreen.next_screen= :kids_menu
    StartScreen.last_screen = :parent_menu
    rmq.screen.open_root_screen(StartScreen)
  end

  def goto_shop

  end

  def goto_options

  end

  def add_story_scroll_view
    @story_layout = UICollectionViewFlowLayout.alloc.init
    @story_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal

    @story_View = UICollectionView.alloc.initWithFrame(CGRectMake(0,NAVBAR_HEIGHT * device.screen_height,
                                                                  device.screen_width, STORY_VIEW_HEIGHT * device.screen_height),
                                                           collectionViewLayout: @story_layout)
    @story_View.dataSource = self
    @story_View.delegate = self

    @story_layout.itemSize = CGSizeMake(0.5 * device.screen_width, @story_View.frame.size.height)

    @story_View.contentInset = UIEdgeInsetsMake(0,0.25 * @story_View.frame.size.width,0,0.25 * @story_View.frame.size.width)


    @story_View.registerClass(UICollectionViewCell, forCellWithReuseIdentifier:CellIdentifier)
    @story_View.backgroundColor = UIColor.clearColor

    @parentmenu.addSubview(@story_View)
  end

  def add_level_scroll_view
    @level_layout = UICollectionViewFlowLayout.alloc.init
    @level_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal

    @level_View = UICollectionView.alloc.initWithFrame(CGRectMake(100,(STORY_VIEW_HEIGHT+ NAVBAR_HEIGHT) * device.screen_height,
                                                                  device.screen_width-200, LEVEL_VIEW_HEIGHT * device.screen_height),
                                                       collectionViewLayout: @level_layout)
    @level_View.dataSource = self
    @level_View.delegate = self

    @level_layout.itemSize = CGSizeMake(0.2 * @level_View.frame.size.width, 0.5 * @level_View.frame.size.height)

    @level_View.contentInset = UIEdgeInsetsMake(0,0,0,0)


    @level_View.registerClass(UICollectionViewCell, forCellWithReuseIdentifier:CellIdentifier)
    @level_View.backgroundColor = UIColor.clearColor

    @parentmenu.addSubview(@level_View)
  end

  # UICollectionView Instance Methods

  def collectionView(view, numberOfItemsInSection:section)
    return 6 if(view == @story_View)
    return 10 if(view == @level_View)
  end

  def collectionView(view, cellForItemAtIndexPath:path)
    c = view.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: path)
    c.backgroundColor = UIColor.orangeColor
    c
  end
end
