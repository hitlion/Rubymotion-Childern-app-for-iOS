class ParentScreen < PM::Screen

  title "Elternmenue"

  LEFT_LABEL_X_POS      = 0.02  # * navbar width
  LEFT_BUTTON_X_POS     = 0.5   # * navbar width
  MIDDLE_BUTTON_X_POS   = 0.6   # * navbar width
  RIGHT_BUTTON_X_POS    = 0.7   # * navbar width
  NAVBAR_ELEMENT_HEIGHT = 0.7   # * navbar height
  NAVBAR_HEIGHT         = 0.125   # * screen_height
  STORY_VIEW_HEIGHT     = 0.39   # * screen_height
  SUB_HEADER_HEIGHT     = 0.08  # * screen_height
  SUB_LINE_HEIGHT       = 0.02  # * screen_height
  LEVEL_VIEW_HEIGHT     = 0.275   # * screen_height
  TAB_BAR_HEIGHT        = 0.11   # * screen_height


  CellIdentifier = 'MyCell'

  def on_load
    lp "test Robert"
  end

  def will_appear

    @babbo_bar_grey = UIColor.colorWithRed(242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha:1.0)
    @babbo_line_grey = UIColor.colorWithRed(200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha:1.0)

    @parentmenu = UIView.alloc.initWithFrame(CGRectMake(0 ,0, device.screen_width, device.screen_height))
    @parentmenu.backgroundColor = UIColor.colorWithRed(255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha:1.0)

    add @parentmenu

    add_nav_bar

    add_story_scroll_view

    add_sub_header

    add_level_scroll_view

    add_tab_bar

    @babbo_grey
  end

  def will_disappear

  end

  def add_nav_bar
    navbar_heigth = NAVBAR_HEIGHT * device.screen_height
    navbar_width = device.screen_width
    navbar_element_height = NAVBAR_ELEMENT_HEIGHT * navbar_heigth

    @own_nav_bar = UIView.alloc.initWithFrame(CGRectMake(0 ,0, navbar_width, navbar_heigth))
    @own_nav_bar.backgroundColor = @babbo_bar_grey

    @parentmenu.addSubview @own_nav_bar

    line = horizontal_line_make(CGPointMake(0,
                                            -1 + (NAVBAR_HEIGHT) * device.screen_height ),
                                width: device.screen_width)

    @parentmenu.addSubview line

    @left_label = UILabel.alloc.initWithFrame(CGRectMake(0.02 * navbar_width,0.2 * navbar_heigth,
                                                         0.5 * navbar_width,navbar_element_height))
    @left_label.text = "Alle Spiele"
    @left_label.font = UIFont.fontWithName("Enriqueta-Bold", size:30)

    @own_nav_bar.addSubview @left_label

    @goto_kids_button = add_button_element_with_image(UIImage.imageNamed("Spielplatz_64.png"),
                                  displayName: "Spielplatz",
                                  fontSize: 11,
                                  position: CGPointMake(0.59 * navbar_width, 0.2 * navbar_heigth),
                                  size: CGSizeMake(navbar_element_height, navbar_element_height),
                                  action: "goto_kids_menu")

    @goto_shop_button = add_button_element_with_image(UIImage.imageNamed("Shop_64.png"),
                                  displayName: "Shop",
                                  fontSize: 11,
                                  position: CGPointMake(0.68 * navbar_width, 0.2 * navbar_heigth),
                                  size: CGSizeMake(navbar_element_height, navbar_element_height),
                                  action: "goto_shop")

    @goto_option_button = add_button_element_with_image(UIImage.imageNamed("Menu_64.png"),
                                  displayName: "Optionen",
                                  fontSize: 11,
                                  position: CGPointMake(0.77 * navbar_width, 0.2 * navbar_heigth),
                                  size: CGSizeMake(navbar_element_height, navbar_element_height),
                                  action: "goto_options")

    @search_bar = add_seach_bar_at_position(CGPointMake(0.84 * navbar_width, 0.05 * navbar_heigth),
                              size: CGSizeMake(0.155 * navbar_width, navbar_element_height),
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
    textField.backgroundColor =@babbo_line_grey

    search_bar
  end

  def add_story_scroll_view
    @story_layout = UICollectionViewFlowLayout.alloc.init
    @story_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal

    @story_view = UICollectionView.alloc.initWithFrame(CGRectMake(0,NAVBAR_HEIGHT * device.screen_height,
                                                                  device.screen_width, STORY_VIEW_HEIGHT * device.screen_height),
                                                           collectionViewLayout: @story_layout)
    @story_view.dataSource = self
    @story_view.delegate = self

    @story_layout.itemSize = CGSizeMake(0.45 * device.screen_width, @story_view.frame.size.height)

    @story_view.contentInset = UIEdgeInsetsMake(0,0.25 * @story_view.frame.size.width,0,0.25 * @story_view.frame.size.width)


    @story_view.registerClass(UICollectionViewCell, forCellWithReuseIdentifier:CellIdentifier)
    @story_view.backgroundColor = UIColor.clearColor

    @parentmenu.addSubview(@story_view)
  end

  def add_sub_header
    @sub_header = UILabel.alloc.initWithFrame(CGRectMake(0.1 * device.screen_width ,
                                                         (STORY_VIEW_HEIGHT + NAVBAR_HEIGHT) * device.screen_height,
                                                         0.8 * device.screen_width,
                                                         SUB_HEADER_HEIGHT * device.screen_height))
    @sub_header.text = "Erstellte Level"
    @sub_header.font = UIFont.fontWithName("Enriqueta-Regular", size:25)
    @parentmenu.addSubview(@sub_header)

    line = horizontal_line_make(CGPointMake(0.1 * device.screen_width,
                                            (STORY_VIEW_HEIGHT + NAVBAR_HEIGHT + SUB_HEADER_HEIGHT) * device.screen_height ),
                                width: 0.8 * device.screen_width)
    @parentmenu.addSubview(line)
  end

  def add_level_scroll_view
    @level_layout = UICollectionViewFlowLayout.alloc.init
    @level_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal

    @level_view = UIView.alloc.initWithFrame(CGRectMake(0,
                                                        (STORY_VIEW_HEIGHT + NAVBAR_HEIGHT + SUB_HEADER_HEIGHT + SUB_LINE_HEIGHT) * device.screen_height,
                                                        device.screen_width,
                                                        LEVEL_VIEW_HEIGHT * device.screen_height))
    @level_view.backgroundColor = UIColor.clearColor


    @level_collection_view = UICollectionView.alloc.initWithFrame(CGRectMake(0.1 * @level_view.frame.size.width , 0,
                                                                  0.8 * @level_view.frame.size.width,
                                                                  @level_view.frame.size.height),
                                                       collectionViewLayout: @level_layout)
    @level_collection_view.dataSource = self
    @level_collection_view.delegate = self

    @level_layout.itemSize = CGSizeMake(0.2 * @level_collection_view.frame.size.width, 0.75 * @level_collection_view.frame.size.height)

    @level_collection_view.contentInset = UIEdgeInsetsMake(0,0,0,0)
    @level_collection_view.backgroundColor = UIColor.clearColor
    @level_collection_view.registerClass(UICollectionViewCell, forCellWithReuseIdentifier:CellIdentifier)

    @level_view.addSubview(@level_collection_view)

    @button_left = UIButton.alloc.initWithFrame(CGRectMake(0, 0,
                                                           0.1 * @level_view.frame.size.width,
                                                           @level_view.frame.size.height))
    @button_left.setImage(UIImage.imageNamed("Pfeil_links_64"), forState:UIControlStateNormal)

    @button_left.addTarget(self, action: "scroll_level_list_right", forControlEvents: UIControlEventTouchUpInside)

    @button_right = UIButton.alloc.initWithFrame(CGRectMake(0.9 * @level_view.frame.size.width , 0,
                                                           0.1 * @level_view.frame.size.width,
                                                           @level_view.frame.size.height))
    @button_right.setImage(UIImage.imageNamed("Pfeil_rechts_64"), forState:UIControlStateNormal)

    @button_right.addTarget(self, action: "scroll_level_list_left", forControlEvents: UIControlEventTouchUpInside)

    @level_view.addSubview(@button_left)
    @level_view.addSubview(@button_right)
    @parentmenu.addSubview(@level_view)
  end

  def add_tab_bar
    @tab_bar = UIView.alloc.initWithFrame(CGRectMake(0, (STORY_VIEW_HEIGHT + NAVBAR_HEIGHT + SUB_HEADER_HEIGHT + SUB_LINE_HEIGHT + LEVEL_VIEW_HEIGHT) * device.screen_height,
                                                      device.screen_width, TAB_BAR_HEIGHT * device.screen_height))
    @tab_bar.backgroundColor = @babbo_bar_grey

    button_size = 0.8 * @tab_bar.frame.size.height

    line = horizontal_line_make(CGPointMake(0,
                                            (STORY_VIEW_HEIGHT + NAVBAR_HEIGHT + SUB_HEADER_HEIGHT + SUB_LINE_HEIGHT + LEVEL_VIEW_HEIGHT) * device.screen_height ),
                                width: device.screen_width)


    @goto_stories_button = add_button_element_with_image(UIImage.imageNamed("Buch_64.png"),
                                                        displayName: "Stories",
                                                        fontSize: 13,
                                                        position: CGPointMake(0.33 * @tab_bar.frame.size.width, 0.1 * @tab_bar.frame.size.height),
                                                        size: CGSizeMake(button_size, button_size),
                                                        action: "goto_stories")

    @goto_videos_button = add_button_element_with_image(UIImage.imageNamed("Videos_64.png"),
                                                       displayName: "Videos",
                                                       fontSize: 13,
                                                       position: CGPointMake(0.465 * @tab_bar.frame.size.width, 0.1 * @tab_bar.frame.size.height),
                                                       size: CGSizeMake(button_size, button_size),
                                                       action: "goto_videos")

    @goto_games_button = add_button_element_with_image(UIImage.imageNamed("Spiele_64.png"),
                                                       displayName: "Spiele",
                                                       fontSize: 13,
                                                       position: CGPointMake(0.6 * @tab_bar.frame.size.width, 0.1 * @tab_bar.frame.size.height),
                                                       size: CGSizeMake(button_size, button_size),
                                                       action: "goto_games")

    @tab_bar.addSubview(@goto_stories_button)
    @tab_bar.addSubview(@goto_videos_button)
    @tab_bar.addSubview(@goto_games_button)

    @parentmenu.addSubview(@tab_bar)
    @parentmenu.addSubview(line)
  end


  ##
  # Adds a element with a button and a label under this button
  #
  # @param image Image for the button
  # @param name Text for the label
  # @param pos The position of the button
  # @param size The size of the button
  #
  def add_button_element_with_image(image, displayName: name, fontSize: font, position: pos, size:size, action: action)
    element =  UIView.alloc.initWithFrame(CGRectMake(pos.x , pos.y, size.width, size.height))

    button = UIButton.alloc.initWithFrame(CGRectMake(0.25 * element.frame.size.width,
                                                     0.05 * element.frame.size.height,
                                                     0.5 * element.frame.size.width,
                                                     0.5 * element.frame.size.height))
    button.setImage(image, forState:UIControlStateNormal)

    button.addTarget(self, action: action, forControlEvents: UIControlEventTouchUpInside)

    label = UILabel.alloc.initWithFrame(CGRectMake(0,
                                                   0.65 * element.frame.size.height,
                                                   element.frame.size.width,
                                                   0.3 * element.frame.size.height))
    label.text = name
    label.font = UIFont.fontWithName("Enriqueta-Regular", size:font)
    label.textAlignment = UITextAlignmentCenter

    element.addSubview button
    element.addSubview label

    element
  end

  def story_view_with_number(num, cell: cell)

    #UIGraphicsBeginImageContext(cell.frame.size)
    #image = UIImage.imageNamed("Testbild.png").drawInRect(cell.backgroundView.bounds)

    #image = UIGraphicsGetImageFromCurrentImageContext()
    #UIGraphicsEndImageContext
    #cell.backgroundColor = UIColor.colorWithPatternImage(image!)

    story = UIView.alloc.initWithFrame(CGRectMake(0,0,2048,1024))
    story.backgroundColor = UIColor.alloc.initWithPatternImage(UIImage.imageNamed("Testbild.png"))

    story

  end

  def horizontal_line_make(position, width: width)
    line = UIView.alloc.initWithFrame(CGRectMake(position.x, position.y, width, 1))
    line.backgroundColor = @babbo_line_grey
    line
  end

  # goto methods

  def goto_kids_menu
    StartScreen.next_screen= :kids_menu
    StartScreen.last_screen = :parent_menu
    rmq.screen.open_root_screen(StartScreen)
  end

  def goto_shop

  end

  def goto_options

  end

  def goto_games

  end

  def goto_stories

  end

  def goto_videos

  end

  def scroll_level_list_left
    c = @level_collection_view.visibleCells.sort!{|pos1, pos2| pos1.frame.origin.x <=> pos2.frame.origin.x}
    @level_collection_view.scrollToItemAtIndexPath(@level_collection_view.indexPathForCell(c[1]),
                                                   atScrollPosition:UICollectionViewScrollPositionLeft, animated:true)
  end

  def scroll_level_list_right
    c = @level_collection_view.visibleCells.sort!{|pos1, pos2| pos2.frame.origin.x <=> pos1.frame.origin.x}
    @level_collection_view.scrollToItemAtIndexPath(@level_collection_view.indexPathForCell(c[1]),
                                                   atScrollPosition:UICollectionViewScrollPositionRight, animated:true)
  end

  # UICollectionView Instance Methods

  def collectionView(view, numberOfItemsInSection:section)
    return 6 if(view == @story_view)
    return 10 if(view == @level_collection_view)
  end

  def collectionView(view, cellForItemAtIndexPath:path)
    c = view.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: path)

    if(view == @story_view)
      #story_view_with_number(1, cell: c)
      #v.frame.size = c.frame.size
      c.backgroundView = story_view_with_number(1, cell: c)
    end


    if(view == @level_collection_view)
      c.backgroundColor = UIColor.yellowColor
    end

    c
  end


end
