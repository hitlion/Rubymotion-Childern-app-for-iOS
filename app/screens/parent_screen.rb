class ParentScreen < PM::Screen

  title "Elternmenue"

  attr_accessor :story_list

  LEFT_LABEL_X_POS      = 0.02  # * navbar width
  LEFT_BUTTON_X_POS     = 0.5   # * navbar width
  MIDDLE_BUTTON_X_POS   = 0.6   # * navbar width
  RIGHT_BUTTON_X_POS    = 0.7   # * navbar width
  NAV_BAR_ELEMENT_HEIGHT = 0.7   # * navbar height
  NAV_BAR_HEIGHT         = 0.125 # * screen_height
  STORY_VIEW_HEIGHT     = 0.39  # * screen_height
  SUB_HEADER_HEIGHT     = 0.08  # * screen_height
  SUB_LINE_HEIGHT       = 0.02  # * screen_height
  LEVEL_VIEW_HEIGHT     = 0.275 # * screen_height
  TAB_BAR_HEIGHT        = 0.11  # * screen_height


  CellIdentifier = 'Cell'

  def will_appear

    @story_list = StoryBundle.bundles.select { |b| b.valid? }


    @story_collection_view_cells = []
    @tips_collection_view_cells = []

    @babbo_bar_grey = UIColor.colorWithRed(247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha:1.0)
    @babbo_line_grey = UIColor.colorWithRed(200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha:1.0)

    @parentmenu = UIView.alloc.initWithFrame(CGRectMake(0 ,0, device.screen_width, device.screen_height))
    @parentmenu.backgroundColor = UIColor.colorWithRed(255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha:1.0)

    add @parentmenu

    build_story_list

    add_nav_bar

    add_story_scroll_view

    add_sub_header

    add_level_scroll_view

    add_tips_and_tricks_view

    add_tab_bar

  end

  def will_disappear

  end

  ##
  # add a own navigation bar
  def add_nav_bar
    navbar_heigth = NAV_BAR_HEIGHT * device.screen_height
    navbar_width = device.screen_width
    navbar_element_height = NAV_BAR_ELEMENT_HEIGHT * navbar_heigth

    @own_nav_bar = UIView.alloc.initWithFrame(CGRectMake(0 ,0, navbar_width, navbar_heigth))
    @own_nav_bar.backgroundColor = @babbo_bar_grey

    @parentmenu.addSubview @own_nav_bar

    line = horizontal_line_make(CGPointMake(0,
                                            -1 + (NAV_BAR_HEIGHT) * device.screen_height ),
                                width: device.screen_width)

    @parentmenu.addSubview line

    @left_label = UILabel.alloc.initWithFrame(CGRectMake(0.02 * navbar_width,0.15 * navbar_heigth,
                                                         0.5 * navbar_width,navbar_element_height))
    @left_label.text = "Alle Spiele"
    @left_label.font = UIFont.fontWithName("Enriqueta-Bold", size:40)

    @own_nav_bar.addSubview @left_label

    @goto_kids_button = add_button_element_with_image(UIImage.imageNamed("Spielplatz_64.png"),
                                  displayName: "Spielplatz",
                                  fontSize: 13,
                                  position: CGPointMake(0.59 * navbar_width, 0.25 * navbar_heigth),
                                  size: CGSizeMake(navbar_element_height, navbar_element_height),
                                  action: "goto_kids_menu")

    @goto_shop_button = add_button_element_with_image(UIImage.imageNamed("Shop_64.png"),
                                  displayName: "Shop",
                                  fontSize: 13,
                                  position: CGPointMake(0.68 * navbar_width, 0.25 * navbar_heigth),
                                  size: CGSizeMake(navbar_element_height, navbar_element_height),
                                  action: "goto_shop")

    @goto_option_button = add_button_element_with_image(UIImage.imageNamed("Menu_64.png"),
                                  displayName: "Optionen",
                                  fontSize: 13,
                                  position: CGPointMake(0.77 * navbar_width, 0.25 * navbar_heigth),
                                  size: CGSizeMake(navbar_element_height, navbar_element_height),
                                  action: "goto_options")

    @search_bar = add_seach_bar_at_position(CGPointMake(0.84 * navbar_width, 0.1 * navbar_heigth),
                              size: CGSizeMake(0.155 * navbar_width, navbar_element_height),
                              placeholder: "Suchen")

    @own_nav_bar.addSubview @goto_kids_button
    @own_nav_bar.addSubview @goto_shop_button
    @own_nav_bar.addSubview @goto_option_button
    @own_nav_bar.addSubview @search_bar

  end

  ##
  # adds the story scoll view
  def add_story_scroll_view

    @story_layout = UICollectionViewFlowLayout.alloc.init
    @story_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal

    @story_view = UICollectionView.alloc.initWithFrame(CGRectMake(0, NAV_BAR_HEIGHT * device.screen_height,
                                                                  device.screen_width, STORY_VIEW_HEIGHT * device.screen_height),
                                                           collectionViewLayout: @story_layout)
    @story_view.dataSource = self
    @story_view.delegate = self

    itemSize = CGSizeMake(0.45 * device.screen_width, @story_view.frame.size.height)

    @story_layout.itemSize = itemSize

    make_story_collection_view_cells(itemSize)

    @story_view.contentInset = UIEdgeInsetsMake(0,0.25 * @story_view.frame.size.width,0,0.25 * @story_view.frame.size.width)


    @story_view.registerClass(UICollectionViewCell, forCellWithReuseIdentifier:CellIdentifier)
    @story_view.backgroundColor = UIColor.clearColor

    @parentmenu.addSubview(@story_view)
  end

  ##
  # add the sub header over the level scroll view
  def add_sub_header
    @sub_header = UILabel.alloc.initWithFrame(CGRectMake(0.1 * device.screen_width ,
                                                         (STORY_VIEW_HEIGHT + NAV_BAR_HEIGHT) * device.screen_height,
                                                         0.8 * device.screen_width,
                                                         SUB_HEADER_HEIGHT * device.screen_height))
    @sub_header.text = "Tipps und Tricks"
    @sub_header.font = UIFont.fontWithName("Enriqueta-Regular", size:25)
    @parentmenu.addSubview(@sub_header)

    line = horizontal_line_make(CGPointMake(0.1 * device.screen_width,
                                            (STORY_VIEW_HEIGHT + NAV_BAR_HEIGHT + SUB_HEADER_HEIGHT) * device.screen_height + 1 ),
                                width: 0.8 * device.screen_width)
    @parentmenu.addSubview(line)
  end

  ##
  # adds tips and tricks section
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

    make_tips_collection_view_cells(size)

    @tips_collection_view.contentInset = UIEdgeInsetsMake(0,0,0,0)
    @tips_collection_view.backgroundColor = UIColor.clearColor
    @tips_collection_view.registerClass(UICollectionViewCell, forCellWithReuseIdentifier:CellIdentifier)

    @tips_view.addSubview(@tips_collection_view)

    @button_left = UIButton.alloc.initWithFrame(CGRectMake(0, 0,
                                                           0.1 * @tips_view.frame.size.width,
                                                           @tips_view.frame.size.height))
    @button_left.setImage(UIImage.imageNamed("previous"), forState:UIControlStateNormal)

    @button_left.addTarget(self, action: "scroll_tips_list_right", forControlEvents: UIControlEventTouchUpInside)

    @button_right = UIButton.alloc.initWithFrame(CGRectMake(0.9 * @tips_view.frame.size.width , 0,
                                                            0.1 * @tips_view.frame.size.width,
                                                            @tips_view.frame.size.height))
    @button_right.setImage(UIImage.imageNamed("next"), forState:UIControlStateNormal)

    @button_right.addTarget(self, action: "scroll_tips_list_left", forControlEvents: UIControlEventTouchUpInside)

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


    @level_collection_view = UICollectionView.alloc.initWithFrame(CGRectMake(0.1 * @level_view.frame.size.width , 0,
                                                                  0.8 * @level_view.frame.size.width,
                                                                  @level_view.frame.size.height),
                                                       collectionViewLayout: @level_layout)
    @level_collection_view.dataSource = self
    @level_collection_view.delegate = self
    @level_collection_view.pagingEnabled = true

    height = 0.75 * @level_collection_view.frame.size.height
    width  = (4 * height) / 3
    size = CGSizeMake(width, height)

    @level_layout.itemSize = size

    make_level_collection_view_cells(size, @stories[0])

    @level_collection_view.contentInset = UIEdgeInsetsMake(0,0,0,0)
    @level_collection_view.backgroundColor = UIColor.clearColor
    @level_collection_view.registerClass(UICollectionViewCell, forCellWithReuseIdentifier:CellIdentifier)

    @level_view.addSubview(@level_collection_view)

    @button_left = UIButton.alloc.initWithFrame(CGRectMake(0, 0,
                                                           0.1 * @level_view.frame.size.width,
                                                           @level_view.frame.size.height))
    @button_left.setImage(UIImage.imageNamed("previous"), forState:UIControlStateNormal)

    @button_left.addTarget(self, action: "scroll_level_list_right", forControlEvents: UIControlEventTouchUpInside)

    @button_right = UIButton.alloc.initWithFrame(CGRectMake(0.9 * @level_view.frame.size.width , 0,
                                                           0.1 * @level_view.frame.size.width,
                                                           @level_view.frame.size.height))
    @button_right.setImage(UIImage.imageNamed("next"), forState:UIControlStateNormal)

    @button_right.addTarget(self, action: "scroll_level_list_left", forControlEvents: UIControlEventTouchUpInside)

    @level_view.addSubview(@button_left)
    @level_view.addSubview(@button_right)
    @parentmenu.addSubview(@level_view)

    @level_view.hidden = true
  end

  ##
  # adds the tab bar
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

  def goto_options

  end

  def goto_games(sender)
    lp ["sender:", sender]
  end

  def goto_stories

  end

  def goto_videos

  end

  def play_story(button)
    cell  = button.superview.superview.superview
    path = @story_view.indexPathForCell(cell)
    story = @story_list[path.row]

    StartScreen.next_story = story
    StartScreen.next_screen = :story_player
    StartScreen.last_screen = :parent_menu
    rmq.screen.open_root_screen(StartScreen)
  end

  ##
  # called if the more / less (left) button was pressed
  # @param button the pressed button object
  def cell_left_button_pressed(button)

    cell  = button.superview.superview.superview
    path = @story_view.indexPathForCell(cell)
    story_level_list = @stories[path.row]

    if(@pressed_more_button)
      if(@pressed_more_button == button)
        @pressed_more_button = nil
        less(story_level_list)
        button.setTitle("Mehr", forState: UIControlStateNormal)
      else
        button.setTitle("Weniger", forState: UIControlStateNormal)
        @pressed_more_button.setTitle("Mehr", forState: UIControlStateNormal)
        more(story_level_list)
        @pressed_more_button = button
      end
    else
      more(story_level_list)
      button.setTitle("Weniger", forState: UIControlStateNormal)
      @pressed_more_button = button
    end
  end

  ##
  # more was pressed (left button in story view cell)
  # rebuild the level list and open the level collection view
  # hide the tipps and tricks section
  def more(list)
    make_level_collection_view_cells(@level_layout.itemSize, list)
    @sub_header.text = "Erstellte Level"
    @level_view.hidden = false
    @tips_view.hidden = true
  end

  ##
  # less was pressed (left button in story view cell)
  # open the tipss and tricks collection view
  # hide the level list section
  def less(story)
    @sub_header.text = "Tipps und Tricks"
    @level_view.hidden = true
    @tips_view.hidden = false
  end

  def scroll_tips_list_left

  end

  def scroll_tips_list_right

  end

  ##
  #
  def scroll_level_list_left
    c = @level_collection_view.visibleCells.sort!{|pos1, pos2| pos1.frame.origin.x <=> pos2.frame.origin.x}
    @level_collection_view.scrollToItemAtIndexPath(@level_collection_view.indexPathForCell(c[1]),
                                                   atScrollPosition:UICollectionViewScrollPositionLeft, animated:true)

    c = @level_collection_view.visibleCells.sort!{|pos1, pos2| pos1.frame.origin.x <=> pos2.frame.origin.x}

    lp @level_collection_view.indexPathForCell(c.last).item

    if (@level_collection_view.indexPathForCell(c.last).item == 9)
      @button_right.hidden = true
    else
      @button_right.hidden = false
    end

    @button_left.hidden = false
  end

  ##
  #
  def scroll_level_list_right
    c = @level_collection_view.visibleCells.sort!{|pos1, pos2| pos2.frame.origin.x <=> pos1.frame.origin.x}
    @level_collection_view.scrollToItemAtIndexPath(@level_collection_view.indexPathForCell(c[1]),
                                                   atScrollPosition:UICollectionViewScrollPositionRight, animated:true)

    c = @level_collection_view.visibleCells.sort!{|pos1, pos2| pos2.frame.origin.x <=> pos1.frame.origin.x}

    if (@level_collection_view.indexPathForCell(c.last).item == 0)
      @button_left.hidden = true
    else
      @button_left.hidden = false
    end

    @button_right.hidden = false
  end

  def build_story_list
   stories = {}

   @story_list.each do |s|
     stories[s.document.document_id] ||= []
     stories[s.document.document_id] << s
   end

   @stories = stories.keys.map { |k| stories[k] }

  end

  ##
  # init the tips and tricks collection cell
  def make_tips_collection_view_cells(itemSize)
    3.times do |index|
      view = UIView.alloc.initWithFrame(CGRectMake(0,0,itemSize.width, itemSize.height))
      view.backgroundColor = UIColor.whiteColor

      label = UILabel.alloc.initWithFrame(CGRectMake(0.05 * view.frame.size.width, 0,
                                                     0.5 * view.frame.size.width, 0.15  * view.frame.size.height))
      label.text = "Super Coole Überschrift"
      label.font = UIFont.fontWithName("Enriqueta-Bold", size:25)
      label.textAlignment = UITextAlignmentCenter

      textView = UITextView.alloc.initWithFrame(CGRectMake(0.05 * view.frame.size.width, 0.2 * view.frame.size.height,
                                                           0.5 * view.frame.size.width, 0.75 * view.frame.size.height ))
      textView.font = UIFont.fontWithName("Enriqueta-Regular", size:20)
      textView.textAlignment = UITextAlignmentLeft

      textView.text = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr,
sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata
 sanctus est Lorem ipsum dolor sit amet."

      image = UIImageView.alloc.initWithFrame(CGRectMake(0.55 * view.frame.size.width,0,0.35 * view.frame.size.width, view.frame.size.height))
      image.image = UIImage.imageNamed("Testbild.png")

      view.addSubview(textView)
      view.addSubview(image)
      view.addSubview(label)

      @tips_collection_view_cells[index] = view
    end

  end

  ##
  # init the level collection view cells
  def make_level_collection_view_cells(itemSize, levelList)

    @level_collection_view_cells = []

    levelList.each_with_index do |level,index|

      view = UIView.alloc.initWithFrame(CGRectMake(0,0,itemSize.width, itemSize.height))
      view.backgroundColor = UIColor.redColor

      image = UIImageView.alloc.initWithFrame(CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
      image.image = UIImage.imageWithData(level.asset_data(level.document.thumbnail))

      view.addSubview(image)

      @level_collection_view_cells[index] = view
    end

    @level_collection_view.reloadData
  end

  ##
  # init the story collection view cells
  def make_story_collection_view_cells(itemSize)
    @stories.each_with_index do |d,index|

      view = UIView.alloc.initWithFrame(CGRectMake(0,0,itemSize.width, itemSize.height))
      view.backgroundColor = UIColor.redColor

      image = UIImageView.alloc.initWithFrame(CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
      image.image = UIImage.imageWithData(d[0].asset_data(d[0].document.thumbnail))

      layer = UIImageView.alloc.initWithFrame(CGRectMake(0, 0, 0.75 * view.frame.size.width, 0.33 * view.frame.size.height ))
      layer.image = UIImage.imageNamed("cell_layer")

      label = UILabel.alloc.initWithFrame(CGRectMake(0, 0, layer.frame.size.width, 0.5 * layer.frame.size.height))
      label.text = d[0].document.set_name
      label.textColor = UIColor.blackColor
      label.font = UIFont.fontWithName("Enriqueta-Bold", size:30)
      label.textAlignment = UITextAlignmentCenter

      left_button = UIButton.alloc.initWithFrame(CGRectMake(0.15 * layer.frame.size.width,0.6 * layer.frame.size.height,
                                                            0.3 * layer.frame.size.width, 0.3 * layer.frame.size.height))
      left_button.setBackgroundImage(UIImage.imageNamed("button_grey.png"), forState:UIControlStateNormal)
      left_button.setTitle("Mehr", forState: UIControlStateNormal)
      left_button.addTarget(self, action: "cell_left_button_pressed:", forControlEvents: UIControlEventTouchUpInside)
      right_button = UIButton.alloc.initWithFrame(CGRectMake(0.55 * layer.frame.size.width,0.6 * layer.frame.size.height,
                                                             0.3 * layer.frame.size.width, 0.3 * layer.frame.size.height))
      right_button.setBackgroundImage(UIImage.imageNamed("button_orange.png"), forState:UIControlStateNormal)
      right_button.setTitle("Spielen", forState: UIControlStateNormal)
      right_button.addTarget(self, action: "play_story:", forControlEvents: UIControlEventTouchUpInside)

      selectedStoryMarker = UIImageView.alloc.initWithFrame(CGRectMake(CGRectGetMidX(view.bounds)- 0.05 *  view.frame.size.width,
                                                                       view.frame.size.height - 0.05 * view.frame.size.width,
                                                                       0.1 * view.frame.size.width, 0.05 * view.frame.size.width))

      selectedStoryMarker.image = UIImage.imageNamed("Marker.png")

      view.addSubview(image)
      view.addSubview(layer)
      view.addSubview(label)
      view.addSubview(left_button)
      view.addSubview(right_button)
      view.addSubview(selectedStoryMarker)

      @story_collection_view_cells[index] = view
    end
  end

  # UICollectionView Instance Methods
  def collectionView(view, numberOfItemsInSection:section)
    return @stories.length if(view == @story_view)
    return @level_collection_view_cells.length if(view == @level_collection_view)
    return 3 if(view == @tips_collection_view)
  end

  def collectionView(view, cellForItemAtIndexPath:path)
    c = view.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: path)

    if(view == @story_view)
      story = @story_collection_view_cells[path.row]
      view = c.contentView
      view.addSubview(story)
    end

    if(view == @level_collection_view)
      level = @level_collection_view_cells[path.row]
      view = c.contentView
      view.addSubview(level)
    end

    if(view == @tips_collection_view)
      tip = @tips_collection_view_cells[path.row]
      view = c.contentView
      view.addSubview(tip)
    end

    c
  end

end
