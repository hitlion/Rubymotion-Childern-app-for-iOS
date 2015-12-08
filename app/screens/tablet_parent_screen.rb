class TabletParentScreen < PM::Screen

  NavbarHeight          = 0.125 # * screen_height
  MiddleViewHeight      = 0.775 # * screen_height
  TabbarHeight          = 0.100 # * screen_height

  CellIdentifier = 'Cell'

  def will_appear

    @parentmenu = UIView.alloc.initWithFrame(CGRectMake(0 ,0, device.screen_width, device.screen_height))
    @parentmenu.backgroundColor = UIColor.whiteColor

    @choosen_story_index ||= 0

    add @parentmenu

    add_nav_bar
    add_menu_view
    add_tab_bar
    add_options
    add_parent_overlay
  end

  ##
  # add a own navigation bar
  def add_nav_bar
    frame = CGRectMake(0, 0, @parentmenu.frame.size.width, NavbarHeight * @parentmenu.frame.size.height)
    navbar = TabletNavbarView.alloc.init_with_frame(frame, titleText: "Alle Spiele", delegate: self)
    @parentmenu.addSubview(navbar)
  end

  def add_menu_view
    frame = CGRectMake(0, NavbarHeight * @parentmenu.frame.size.height,
                       @parentmenu.frame.size.width, MiddleViewHeight * @parentmenu.frame.size.height)
    @menu_view = TabletMenuView.alloc.init_with_frame(frame, delegate: self)
    @parentmenu.addSubview(@menu_view)
  end

  ##
  # adds the tab bar at the bottom of the screen
  def add_tab_bar
    frame = CGRectMake(0, (NavbarHeight + MiddleViewHeight) *  @parentmenu.frame.size.height,
                       @parentmenu.frame.size.width, TabbarHeight * @parentmenu.frame.size.height)
    @tab_bar = TabbarView.alloc.init_with_frame(frame, delegate: self)
    @parentmenu.addSubview(@tab_bar)
  end

  ##
  # add options view
  def add_options
    frame = CGRectMake(0, NavbarHeight * @parentmenu.frame.size.height - 1,
                       @parentmenu.frame.size.width,
                       @parentmenu.frame.size.height - NavbarHeight * @parentmenu.frame.size.height + 1)
    @options_view = TabletOptionView.alloc.init_with_frame(frame)
    @parentmenu.addSubview(@options_view)
  end

  def add_parent_overlay
    @parent_overlay ||= TabletOverlayView.alloc.init_with_type(:parent_menu, frame: CGRectMake(0, 0, device.screen_width, device.screen_height))
    @parent_overlay.hidden = true
    @parentmenu.addSubview(@parent_overlay)
  end

  ##
  # instance method for TabletNavbarView
  # @param view [TabletNavbarView] The navbar object
  # @param button [UIButton] The button object with unique tags
  def tabletNavbarView(view, buttonPressed: button)
    button_id = button.tag

    if (button_id == 0)
      lp "back button pressed"
    elsif (button_id == 1)
      StartScreen.next_screen= :shop_menu
      StartScreen.last_screen = :parent_menu
      rmq.screen.open_root_screen(StartScreen)
    elsif (button_id == 2)
      lp "go to shop"
      StartScreen.next_screen= :shop_menu
      StartScreen.last_screen = :parent_menu
      rmq.screen.open_root_screen(StartScreen)
    elsif (button_id == 3)
      @options_view.hidden = !@options_view.hidden?
    end
  end

  ##
  # instance method for TabletMenuView
  # @param view [TabletMenuView] The tabletMenuView object
  # @param cell [UICollectioViewCell] The pressed cell
  # @param source [UIButton] The pressed button object
  def tabletMenuView(view, storyObject: story)
    if(view == @menu_view)
      @parent_overlay.reload_view_with_story(story)
      @parent_overlay.hidden = !@parent_overlay.hidden?
    end
  end

end
