class ParentScreen < PM::Screen

  title "Elternmenue"

  attr_accessor :story_list

  LEFT_LABEL_X_POS      = 0.02  # * navbar width
  LEFT_BUTTON_X_POS     = 0.5   # * navbar width
  MIDDLE_BUTTON_X_POS   = 0.6   # * navbar width
  RIGHT_BUTTON_X_POS    = 0.7   # * navbar width
  NAV_BAR_HEIGHT        = 0.125 # * screen_height
  STORY_VIEW_HEIGHT     = 0.39  # * screen_height
  SUB_HEADER_HEIGHT     = 0.08  # * screen_height
  SUB_LINE_HEIGHT       = 0.02  # * screen_height
  LEVEL_VIEW_HEIGHT     = 0.275 # * screen_height
  TAB_BAR_HEIGHT        = 0.11  # * screen_height


  CellIdentifier = 'Cell'

  def will_appear

    @babbo_bar_grey = UIColor.colorWithRed(247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha:1.0)
    @babbo_line_grey = UIColor.colorWithRed(200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha:1.0)
    @babbo_orange = UIColor.colorWithRed(249.0/255.0, green: 188.0/255.0, blue: 52.0/255.0, alpha:1.0)

    @parentmenu = UIView.alloc.initWithFrame(CGRectMake(0 ,0, device.screen_width, device.screen_height))
    @parentmenu.backgroundColor = UIColor.colorWithRed(255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha:1.0)

    @choosen_story_index ||= 0

    add @parentmenu

    build_story_list

    add_nav_bar
    add_story_scroll_view
    add_sub_header
    add_level_scroll_view
    add_tips_and_tricks_view
    add_tab_bar
    add_options
    add_parent_overlay

  end

  def will_disappear

  end

  ##
  # add a own navigation bar
  def add_nav_bar
    navbar_heigth = NAV_BAR_HEIGHT * device.screen_height
    navbar_width = device.screen_width

    @nav_bar = UIView.alloc.initWithFrame(CGRectMake(0 ,0, navbar_width, navbar_heigth))
    @nav_bar.backgroundColor = @babbo_bar_grey

    @parentmenu.addSubview @nav_bar

    line = horizontal_line_make(CGPointMake(0, -1 + (NAV_BAR_HEIGHT) * device.screen_height),
                                width: device.screen_width)

    @parentmenu.addSubview line

    @left_label = UILabel.alloc.initWithFrame(CGRectMake(0.02 * @nav_bar.frame.size.width,
                                                         0.15 * @nav_bar.frame.size.height,
                                                         0.5  * @nav_bar.frame.size.width,
                                                         0.85 * @nav_bar.frame.size.height))
    @left_label.text = "Alle Spiele"
    @left_label.font = UIFont.fontWithName("Enriqueta-Bold", size:40)

    @nav_bar.addSubview @left_label

    @goto_kids_button = add_button_element_with_image(UIImage.imageNamed("Spielplatz_64.png"),
                                  displayName: "Spielplatz",
                                  fontSize: 13,
                                  position: CGPointMake(0.55 * @nav_bar.frame.size.width, 0.2 *  @nav_bar.frame.size.height),
                                  size: CGSizeMake(0.075 * @nav_bar.frame.size.width,
                                                   0.075 * @nav_bar.frame.size.width),
                                  action: "goto_kids_menu")

    @goto_shop_button = add_button_element_with_image(UIImage.imageNamed("Shop_64.png"),
                                  displayName: "Shop",
                                  fontSize: 13,
                                  position: CGPointMake(0.65 * @nav_bar.frame.size.width, 0.2 *  @nav_bar.frame.size.height),
                                  size: CGSizeMake(0.075 * @nav_bar.frame.size.width,
                                                   0.075 * @nav_bar.frame.size.width),
                                  action: "goto_shop")

    @goto_option_button = add_button_element_with_image(UIImage.imageNamed("Menu_64.png"),
                                  displayName: "Optionen",
                                  fontSize: 13,
                                  position: CGPointMake(0.75 * @nav_bar.frame.size.width, 0.2 *  @nav_bar.frame.size.height),
                                  size: CGSizeMake(0.075 * @nav_bar.frame.size.width,
                                                   0.075 * @nav_bar.frame.size.width),
                                  action: "open_options:")

    @options_button_background = UIImageView.alloc.initWithFrame(CGRectMake(0.75 * @nav_bar.frame.size.width,
                                                                            0.2  * @nav_bar.frame.size.height,
                                                                            0.075 * @nav_bar.frame.size.width,
                                                                            0.8 * @nav_bar.frame.size.height+1))
    @options_button_background.image = UIImage.imageNamed("option_button_background.png")
    @options_button_background.hidden = true


    @search_bar = add_seach_bar_at_position(CGPointMake(0.83 * @nav_bar.frame.size.width, 0.07 *  @nav_bar.frame.size.height),
                              size: CGSizeMake(0.155 * @nav_bar.frame.size.width, 0.75 * @nav_bar.frame.size.height),
                              placeholder: "Suchen")

    @nav_bar.addSubview @goto_kids_button
    @nav_bar.addSubview @goto_shop_button
    @nav_bar.addSubview @options_button_background
    @nav_bar.addSubview @goto_option_button
    @nav_bar.addSubview @search_bar

  end

  ##
  # adds the story scoll view
  def add_story_scroll_view

    @story_layout = UICollectionViewFlowLayout.alloc.init
    @story_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal

    @story_collection_view = UICollectionView.alloc.initWithFrame(CGRectMake(0, NAV_BAR_HEIGHT * device.screen_height,
                                                                             device.screen_width, STORY_VIEW_HEIGHT * device.screen_height),
                                                                  collectionViewLayout: @story_layout)
    @story_collection_view.dataSource = self
    @story_collection_view.delegate = self

    height = @story_collection_view.frame.size.height
    width  = (4 * height) / 3
    size = CGSizeMake(width, height)

    @story_layout.itemSize = size

    @story_collection_view.contentInset = UIEdgeInsetsMake(0, 0 * @story_collection_view.frame.size.width, 0, 0 * @story_collection_view.frame.size.width)


    @story_collection_view.registerClass(MenuStoryCell, forCellWithReuseIdentifier:CellIdentifier)
    @story_collection_view.backgroundColor = UIColor.clearColor

    @parentmenu.addSubview(@story_collection_view)
  end

  ##
  # add the sub header over the level scroll view
  def add_sub_header
    @sub_header = UILabel.alloc.initWithFrame(CGRectMake(0.075 * device.screen_width ,
                                                         (STORY_VIEW_HEIGHT + NAV_BAR_HEIGHT) * device.screen_height,
                                                         0.85 * device.screen_width,
                                                         SUB_HEADER_HEIGHT * device.screen_height))
    @sub_header.text = "Tipps und Tricks"
    @sub_header.font = UIFont.fontWithName("Enriqueta-Regular", size:25)
    @parentmenu.addSubview(@sub_header)

    line = horizontal_line_make(CGPointMake(0.075 * device.screen_width,
                                            (STORY_VIEW_HEIGHT + NAV_BAR_HEIGHT + SUB_HEADER_HEIGHT) * device.screen_height + 1 ),
                                width: 0.85 * device.screen_width)
    @parentmenu.addSubview(line)
  end

  ##
  # adds tips and tricks collection view
  def add_tips_and_tricks_view
    @tips_layout = UICollectionViewFlowLayout.alloc.init
    @tips_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal

    @tips_view = UIView.alloc.initWithFrame(CGRectMake(0,
                                                        (STORY_VIEW_HEIGHT + NAV_BAR_HEIGHT + SUB_HEADER_HEIGHT + SUB_LINE_HEIGHT) * device.screen_height,
                                                        device.screen_width,
                                                        LEVEL_VIEW_HEIGHT * device.screen_height))
    @tips_view.backgroundColor = UIColor.clearColor


    @tips_collection_view = UICollectionView.alloc.initWithFrame(CGRectMake(0.1 * @tips_view.frame.size.width , 0,
                                                                             0.8 * @tips_view.frame.size.width,
                                                                             @tips_view.frame.size.height),
                                                                  collectionViewLayout: @tips_layout)
    @tips_collection_view.dataSource = self
    @tips_collection_view.delegate = self
    @tips_collection_view.pagingEnabled = true

    height = 0.95 * @tips_collection_view.frame.size.height
    width  = @tips_collection_view.frame.size.width
    size = CGSizeMake(width, height)

    @tips_layout.itemSize = size

    make_tips_list

    @tips_collection_view.contentInset = UIEdgeInsetsMake(0,0,0,0)
    @tips_collection_view.backgroundColor = UIColor.clearColor
    @tips_collection_view.registerClass(MenuTipsCell, forCellWithReuseIdentifier:CellIdentifier)

    @tips_view.addSubview(@tips_collection_view)

    @button_left = UIButton.alloc.initWithFrame(CGRectMake(0, 0,
                                                           0.075 * @tips_view.frame.size.width,
                                                           @tips_view.frame.size.height))
    @button_left.setImage(UIImage.imageNamed("previous"), forState:UIControlStateNormal)

    @button_left.addTarget(self, action: "scroll_tips_list:", forControlEvents: UIControlEventTouchUpInside)
    @button_left.tag = -1

    @button_right = UIButton.alloc.initWithFrame(CGRectMake(0.925 * @tips_view.frame.size.width , 0,
                                                            0.075 * @tips_view.frame.size.width,
                                                            @tips_view.frame.size.height))
    @button_right.setImage(UIImage.imageNamed("next"), forState:UIControlStateNormal)

    @button_right.addTarget(self, action: "scroll_tips_list:", forControlEvents: UIControlEventTouchUpInside)
    @button_right.tag = +1

    @tips_view.addSubview(@button_left)
    @tips_view.addSubview(@button_right)
    @parentmenu.addSubview(@tips_view)
  end

  ##
  # adds the level scroll view
  def add_level_scroll_view

    @level_layout = UICollectionViewFlowLayout.alloc.init
    @level_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal

    @level_view = UIView.alloc.initWithFrame(CGRectMake(0,
                                                        (STORY_VIEW_HEIGHT + NAV_BAR_HEIGHT + SUB_HEADER_HEIGHT + SUB_LINE_HEIGHT) * device.screen_height,
                                                        device.screen_width,
                                                        LEVEL_VIEW_HEIGHT * device.screen_height))
    @level_view.backgroundColor = UIColor.clearColor


    @level_collection_view = UICollectionView.alloc.initWithFrame(CGRectMake(0.075 * @level_view.frame.size.width , 0,
                                                                  0.85 * @level_view.frame.size.width,
                                                                  @level_view.frame.size.height),
                                                       collectionViewLayout: @level_layout)
    @level_collection_view.dataSource = self
    @level_collection_view.delegate = self
    @level_collection_view.pagingEnabled = true

    gap = 20
    @level_layout.minimumLineSpacing = gap
    width  = (@level_collection_view.frame.size.width - 3 * gap) / 4.0
    height = width
    size = CGSizeMake(width, height)

    @level_layout.itemSize = size

    @level_collection_view.contentInset = UIEdgeInsetsMake(0,0,0,0)
    @level_collection_view.backgroundColor = UIColor.clearColor
    @level_collection_view.registerClass(MenuLevelCell, forCellWithReuseIdentifier:CellIdentifier)

    @level_view.addSubview(@level_collection_view)

    @button_left = UIButton.alloc.initWithFrame(CGRectMake(0, 0,
                                                           0.075 * @level_view.frame.size.width,
                                                           @level_view.frame.size.height))
    @button_left.setImage(UIImage.imageNamed("previous"), forState:UIControlStateNormal)

    @button_left.addTarget(self, action: "scroll_level_list_right", forControlEvents: UIControlEventTouchUpInside)

    @button_right = UIButton.alloc.initWithFrame(CGRectMake(0.925 * @level_view.frame.size.width , 0,
                                                           0.075 * @level_view.frame.size.width,
                                                           @level_view.frame.size.height))
    @button_right.setImage(UIImage.imageNamed("next"), forState:UIControlStateNormal)

    @button_right.addTarget(self, action: "scroll_level_list_left", forControlEvents: UIControlEventTouchUpInside)

    @level_view.addSubview(@button_left)
    @level_view.addSubview(@button_right)
    @parentmenu.addSubview(@level_view)

    @level_view.hidden = true
  end

  ##
  # adds the tab bar at the bottom of the screen
  def add_tab_bar
    @tab_bar = UIView.alloc.initWithFrame(CGRectMake(0, (STORY_VIEW_HEIGHT + NAV_BAR_HEIGHT + SUB_HEADER_HEIGHT + SUB_LINE_HEIGHT + LEVEL_VIEW_HEIGHT) * device.screen_height,
                                                      device.screen_width, TAB_BAR_HEIGHT * device.screen_height))
    @tab_bar.backgroundColor = @babbo_bar_grey

    button_size = 0.8 * @tab_bar.frame.size.height

    line = horizontal_line_make(CGPointMake(0,
                                            (STORY_VIEW_HEIGHT + NAV_BAR_HEIGHT + SUB_HEADER_HEIGHT + SUB_LINE_HEIGHT + LEVEL_VIEW_HEIGHT) * device.screen_height ),
                                width: device.screen_width)


    @goto_stories_button = add_button_element_with_image(UIImage.imageNamed("Buch_64.png"),
                                                        displayName: "Stories",
                                                        fontSize: 15,
                                                        position: CGPointMake(0.33 * @tab_bar.frame.size.width, 0.1 * @tab_bar.frame.size.height),
                                                        size: CGSizeMake(button_size, button_size),
                                                        action: "goto_stories")

    @goto_videos_button = add_button_element_with_image(UIImage.imageNamed("Videos_64.png"),
                                                       displayName: "Videos",
                                                       fontSize: 15,
                                                       position: CGPointMake(0.465 * @tab_bar.frame.size.width, 0.1 * @tab_bar.frame.size.height),
                                                       size: CGSizeMake(button_size, button_size),
                                                       action: "goto_videos")

    @goto_games_button = add_button_element_with_image(UIImage.imageNamed("Spiele_64.png"),
                                                       displayName: "Spiele",
                                                       fontSize: 15,
                                                       position: CGPointMake(0.6 * @tab_bar.frame.size.width, 0.1 * @tab_bar.frame.size.height),
                                                       size: CGSizeMake(button_size, button_size),
                                                       action: "goto_games:")

    @tab_bar.addSubview(@goto_stories_button)
    @tab_bar.addSubview(@goto_videos_button)
    @tab_bar.addSubview(@goto_games_button)

    @parentmenu.addSubview(@tab_bar)
    @parentmenu.addSubview(line)
  end

  ##
  # add options view
  def add_options

    @options_view = UIView.alloc.initWithFrame(CGRectMake(0, -1 + NAV_BAR_HEIGHT * device.screen_height ,
                                                          device.screen_width, device.screen_height - (NAV_BAR_HEIGHT * device.screen_height)))
    @options_view.backgroundColor = UIColor.clearColor

    options_table = UIImageView.alloc.initWithFrame(CGRectMake(0.75 * @options_view.frame.size.width, 0,
                                                          0.25 * @options_view.frame.size.width, @options_view.frame.size.height))
    options_table.image = UIImage.imageNamed("option_background.png")

    parent_image = UIImageView.alloc.initWithFrame(CGRectMake(0.1 * options_table.frame.size.width,
                                                              (1.0/32.0) * options_table.frame.size.height,
                                                              0.8 * options_table.frame.size.width,
                                                              (9.0/32.0) * options_table.frame.size.height))
    parent_image.backgroundColor = UIColor.clearColor
    parent_image.image = UIImage.imageNamed("dummy_parent.png")

    parent_name = UILabel.alloc.initWithFrame(CGRectMake(0,
                                                         (10/32.0) * options_table.frame.size.height,
                                                         options_table.frame.size.width,
                                                         (1.0/32.0) * options_table.frame.size.height))
    parent_name.text = "Username"
    parent_name.font = UIFont.fontWithName("Enriqueta-Regular", size:20)
    parent_name.textColor = @babbo_orange
    parent_name.textAlignment = UITextAlignmentCenter

    table = UIView.alloc.initWithFrame(CGRectMake(0,
                                                  (12.0/32.0) * options_table.frame.size.height,
                                                  options_table.frame.size.width,
                                                  (10.0/32.0) * options_table.frame.size.height))
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
    lineBottom.backgroundColor = @babbo_line_grey
    tableButton_4.addSubview(lineBottom)

    table.addSubview(tableButton_1)
    table.addSubview(tableButton_2)
    table.addSubview(tableButton_3)
    table.addSubview(tableButton_4)



    logo = UIImageView.alloc.initWithFrame(CGRectMake(0.1 * options_table.frame.size.width,
                                                      (22.0/32.0) * options_table.frame.size.height,
                                                      0.8 * options_table.frame.size.width,
                                                      (9.0/32.0) * options_table.frame.size.height))
    logo.image = UIImage.imageNamed("Logo_Orange.png")

    version_number = UILabel.alloc.initWithFrame(CGRectMake(0,
                                                            (31.0/32.0) * options_table.frame.size.height,
                                                            options_table.frame.size.width,
                                                            (1.0/32.0) * options_table.frame.size.height))
    version_number.text = app.version
    version_number.font = UIFont.fontWithName("Enriqueta-Regular", size:15)
    version_number.textAlignment = UITextAlignmentCenter

    options_table.addSubview(parent_image)
    options_table.addSubview(parent_name)
    options_table.addSubview(table)
    options_table.addSubview(logo)
    options_table.addSubview(version_number)

    @options_view.hidden = true
    @options_view.addSubview(options_table)
    @parentmenu.addSubview(@options_view)
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
    lineTop.backgroundColor = @babbo_line_grey

    view.addSubview(imageView)
    view.addSubview(labelView)
    view.addSubview(lineTop)

    button.addSubview(view)

    button
  end

  def add_parent_overlay
    @parent_overlay ||= MenuOverlay.alloc.initWithType(:parent_menu, frame: CGRectMake(0, 0, device.screen_width, device.screen_height))
    @parent_overlay.hidden = true
    @parentmenu.addSubview(@parent_overlay)
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

    button.addTarget(self, action: action, forControlEvents: UIControlEventTouchDown)

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

  ##
  # Adds a search bar
  #
  # @param pos The search bar position
  # @param size The size of the button
  # @param ph The placeholder string
  #
  def add_seach_bar_at_position(pos, size: size, placeholder: ph)
    search_bar = UISearchBar.alloc.initWithFrame(CGRectMake(pos.x, pos.y, size.width, size.height))
    search_bar.placeholder = ph
    search_bar.backgroundImage = UIImage.alloc.init

    textField = UITextField.appearanceWhenContainedIn(UISearchBar,nil)
    textField.backgroundColor =@babbo_line_grey

    search_bar
  end

  ##
  # Adds a horizontal line in babbo grey
  #
  # @param position The postition fot the line
  # @param width The width of the line
  #
  def horizontal_line_make(position, width: width)
    line = UIView.alloc.initWithFrame(CGRectMake(position.x, position.y, width, 1))
    line.backgroundColor = @babbo_line_grey
    line
  end

  ##
  # goto methods
  #
  # set the next_screen property of StartScreen and save the current screen in last_screen
  # then open the root_screen with open_root_screen(StartScreen)
  #
  def goto_kids_menu
    StartScreen.next_screen= :kids_menu
    StartScreen.last_screen = :parent_menu
    rmq.screen.open_root_screen(StartScreen)
  end

  def goto_shop
    StartScreen.next_screen= :shop_menu
    StartScreen.last_screen = :parent_menu
    rmq.screen.open_root_screen(StartScreen)
  end

  def open_options(button)
    @options_view.hidden = !@options_view.hidden?
    @options_button_background.hidden = !@options_button_background.hidden?
  end

  def goto_games(sender)
    lp ["sender:", sender]
  end

  def goto_stories

  end

  def goto_videos

  end

  ##
  # instance methods for MenuStoryCell

  def menuStoryCell(cell, rightButtonPressed: source)
    id  = source.tag
    story = @story_list.find {|e| e.object_id == id}

    @parent_overlay.reload_view_with_story(story)
    @parent_overlay.hidden = !@parent_overlay.hidden?
  end

  def menuStoryCell(cell, leftButtonPressed: source)
    id  = source.tag

    story_level_list = @stories.find {|e| e[0].object_id == id}
    index = @stories.index (story_level_list)
    path = NSIndexPath.indexPathForRow(index, inSection:0)

    @choosen_story_index = index

    if(@pressed_more_button)
      if(@pressed_more_button == source)
        @pressed_more_button = nil
        less(story_level_list)
        source.setTitle("Mehr", forState: UIControlStateNormal)
        cell.hide_marker
      else
        source.setTitle("Weniger", forState: UIControlStateNormal)
        @pressed_more_button.setTitle("Mehr", forState: UIControlStateNormal)
        more(story_level_list, path: path)
        @pressed_more_button = source
        cell.show_marker
        @lastSelectedCell.hide_marker
      end
    else
      more(story_level_list, path: path)
      source.setTitle("Weniger", forState: UIControlStateNormal)
      @pressed_more_button = source
      cell.show_marker
    end

    @lastSelectedCell = cell
  end

  ##
  # instance methods for MenuLevelCell
  def menuLevelCell(cell, buttonPressed: source)
    id  = source.tag
    story = @story_list.find {|e| e.object_id == id}

    @parent_overlay.reload_view_with_story(story)
    @parent_overlay.hidden = !@parent_overlay.hidden?
  end

  ##
  # more was pressed (left button in menu story view cell)
  # rebuild the level list and open the level collection view
  # hide the tipps and tricks section
  def more(list, path: path)
    reload_level_collection_view_cells
    @sub_header.text = "Erstellte Level"
    @level_view.hidden = false
    @tips_view.hidden = true

    @story_collection_view.scrollToItemAtIndexPath(path, atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally, animated:true)
  end

  ##
  # less was pressed (left button in menu story view cell)
  # open the tipss and tricks collection view
  # hide the level list section
  def less(story)
    @sub_header.text = "Tipps und Tricks"
    @level_view.hidden = true
    @tips_view.hidden = false
  end

  ##
  # Scroll the tips and tricks section
  # @param source The source (button)
  def scroll_tips_list(source)
    cells = @tips_collection_view.visibleCells
    path = @tips_collection_view.indexPathForCell(cells[0])
    direction = source.tag
    row = path.row + direction

    if(row == @tips_collection_view.numberOfItemsInSection(0))
      row = @tips_collection_view.numberOfItemsInSection(0) - 1
    end

    if(row == -1)
      row = 0
    end

    destination = NSIndexPath.indexPathForRow(row, inSection:0)

    @tips_collection_view.scrollToItemAtIndexPath(destination, atScrollPosition:UICollectionViewScrollPositionLeft, animated:true)

  end

  ##
  #
  def scroll_level_list_left
    c = @level_collection_view.visibleCells.sort!{|pos1, pos2| pos1.frame.origin.x <=> pos2.frame.origin.x}
    @level_collection_view.scrollToItemAtIndexPath(@level_collection_view.indexPathForCell(c[1]),
                                                   atScrollPosition:UICollectionViewScrollPositionLeft, animated:true)
  end

  ##
  #
  def scroll_level_list_right
    c = @level_collection_view.visibleCells.sort!{|pos1, pos2| pos2.frame.origin.x <=> pos1.frame.origin.x}
    @level_collection_view.scrollToItemAtIndexPath(@level_collection_view.indexPathForCell(c[1]),
                                                   atScrollPosition:UICollectionViewScrollPositionRight, animated:true)
  end

  def build_story_list
   @story_list = StoryBundle.bundles.select { |b| b.valid? }
   stories = {}

   @story_list.each do |s|
     stories[s.document.document_id] ||= []
     stories[s.document.document_id] << s
   end

   @stories = stories.keys.map { |k| stories[k] }

  end

  ##
  # init the tips and tricks collection cell
  def make_tips_list
    @tips_list = TipsBundle.alloc.init
  end

  ##
  # init the level collection view cells
  def reload_level_collection_view_cells
    @level_collection_view.reloadData
  end

  # UICollectionView Instance Methods
  def collectionView(view, numberOfItemsInSection:section)
    return @stories.length if(view == @story_collection_view)
    return @stories[@choosen_story_index].length if(view == @level_collection_view)
    return @tips_list.length if(view == @tips_collection_view)
  end

  def collectionView(view, cellForItemAtIndexPath:path)
    cell = view.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: path)

    if(view == @story_collection_view)
      list = @stories[path.row]
      cell.delegate = self
      cell.make_cell(list[0])
    end

    if(view == @level_collection_view)
      list = @stories[@choosen_story_index]
      element = list[path.row]
      cell.delegate = self
      cell.make_cell(element)
    end

    if(view == @tips_collection_view)
      cell.make_cell(@tips_list[path.row])
    end

    cell
  end

end
