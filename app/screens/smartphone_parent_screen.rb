class SmartphoneParentScreen < PM::Screen

  NavbarHeight          = 0.150 # * screen_height
  MiddleViewHeight      = 0.700 # * screen_height
  TabbarHeight          = 0.150 # * screen_height

  CellIdentifier = 'Cell'

  def will_appear

    @parentmenu = UIView.alloc.initWithFrame(CGRectMake(0 ,0, device.screen_width, device.screen_height))
    @parentmenu.backgroundColor = UIColor.whiteColor

    @choosen_story_index ||= 0

    add @parentmenu

    add_nav_bar
    add_menu_view
    add_shop_view
    add_tab_bar
    add_options
    add_menu_overlay
    add_shop_premium_overlay
    add_shop_basic_overlay
  end

  ##
  # add a own navigation bar
  def add_nav_bar
    frame = CGRectMake(0, 0, @parentmenu.frame.size.width, NavbarHeight * @parentmenu.frame.size.height)
    @navbar = SmartphoneNavbarView.alloc.init_with_frame(frame, titleText: "Alle Spiele", delegate: self)
    @parentmenu.addSubview(@navbar)
  end

  def add_menu_view
    frame = CGRectMake(0, NavbarHeight * @parentmenu.frame.size.height,
                       @parentmenu.frame.size.width, MiddleViewHeight * @parentmenu.frame.size.height)
    @menu_view = SmartphoneMenuView.alloc.init_with_frame(frame, delegate: self)
    @parentmenu.addSubview(@menu_view)
  end

  def add_shop_view
    frame = CGRectMake(0, NavbarHeight * @parentmenu.frame.size.height,
                       @parentmenu.frame.size.width, MiddleViewHeight * @parentmenu.frame.size.height)
    @shop_view = TabletShopView.alloc.init_with_frame(frame, delegate: self)
    @shop_view.hidden = true
    @parentmenu.addSubview(@shop_view)
  end

  ##
  # adds the tab bar at the bottom of the screen
  def add_tab_bar
    frame = CGRectMake(0, (NavbarHeight + MiddleViewHeight) *  @parentmenu.frame.size.height,
                       @parentmenu.frame.size.width, TabbarHeight * @parentmenu.frame.size.height)
    @tab_bar = SmartphoneTabbarView.alloc.init_with_frame(frame, delegate: self)
    @parentmenu.addSubview(@tab_bar)
  end

  ##
  # add options view
  def add_options
    frame = CGRectMake(0, NavbarHeight * @parentmenu.frame.size.height - 1,
                       @parentmenu.frame.size.width,
                       @parentmenu.frame.size.height - NavbarHeight * @parentmenu.frame.size.height + 1)
    @options_view = TabletOptionView.alloc.init_with_frame(frame, delegate: self)
    @parentmenu.addSubview(@options_view)
  end

  def add_menu_overlay
    frame = CGRectMake(0, 0, device.screen_width, device.screen_height)
    @parent_menu_overlay ||= TabletOverlayView.alloc.init_with_type(OverlayMenuStandard.alloc.init, frame: frame)
    @parent_menu_overlay.hidden = true
    @parentmenu.addSubview(@parent_menu_overlay)
  end

  def add_shop_premium_overlay
    frame = CGRectMake(0, 0, device.screen_width, device.screen_height)
    @parent_shop_premium_overlay ||= TabletOverlayView.alloc.init_with_type(OverlayShopPremium.alloc.init, frame: frame)
    @parent_shop_premium_overlay.hidden = true
    @parentmenu.addSubview(@parent_shop_premium_overlay)
  end

  def add_shop_basic_overlay
    frame = CGRectMake(0, 0, device.screen_width, device.screen_height)
    @parent_shop_basic_overlay ||= TabletOverlayView.alloc.init_with_type(OverlayShopBasic.alloc.init, frame: frame)
    @parent_shop_basic_overlay.hidden = true
    @parentmenu.addSubview(@parent_shop_basic_overlay)
  end

  ##
  # instance method for TabletOptionView
  # called if the optionview is closed
  # @param view [TabletNavbarView] The view object
  def tabletOptionViewClosed(view)
    @navbar.set_last_selected_button_inactive
  end

  ##
  # instance method for TabletNavbarView, called if a button is pressed
  # @param view [TabletNavbarView] The navbar object
  # @param button [UIButton] The button object with unique tags
  def tabletNavbarView(view, buttonPressed: button)
    button_id = button.tag

    lp button_id
    if (button_id == 0)
      @shop_view.hidden = true
      @menu_view.hidden = false
      @navbar.hide_back_button
      @navbar.set_title_text("Alle Stories")
      @navbar.set_last_selected_button_inactive
    elsif (button_id == 1)
      StartScreen.next_screen= :kids_menu
      StartScreen.last_screen = :parent_menu
      rmq.screen.open_root_screen(StartScreen)
    elsif (button_id == 2)
      if(@shop_view.hidden?)
        @navbar.set_title_text("Shop")
        @shop_view.hidden = false
        @menu_view.hidden = true
        @navbar.show_back_button
        @options_view.hidden = true
      end
    elsif (button_id == 3)
      @options_view.hidden = !@options_view.hidden?
      @shop_view.hidden = true
      @menu_view.hidden = false
      @navbar.hide_back_button
      @navbar.set_title_text("Alle Stories")
    end
  end

  def tabbarView(view, buttonPressed: source)
    id = source.tag
    if (id == 1)
      StartScreen.next_screen= :story_list
      StartScreen.last_screen = :parent_menu
      rmq.screen.open_root_screen(StartScreen)
    end
  end

  ##
  # instance method for TabletMenuView
  # @param view [TabletMenuView] The tabletMenuView object
  # @param cell [UICollectioViewCell] The pressed cell
  # @param source [UIButton] The pressed button object
  def tabletMenuView(view, storyObject: story)
    if(view == @menu_view)
      @parent_menu_overlay.reload_view_with_story(story)
      @parent_menu_overlay.hidden = !@parent_menu_overlay.hidden?
    end
  end

  ##
  # instance method for TabletShopView, called if a cell (story) is pressed
  # @param view [TabletMenuView] The tabletMenuView object
  # @param cell [UICollectioViewCell] The pressed cell
  # @param source [UIButton] The pressed button object
  def tabletShopView(view, cell: cell, storyObject: story)
    if(view == @shop_view)
      if(cell.class == ShopPremiumCell)
        @parent_shop_premium_overlay.reload_view_with_story(story)
        @parent_shop_premium_overlay.hidden = !@parent_shop_premium_overlay.hidden?
      elsif(cell.class == ShopBasicCell)
        @parent_shop_basic_overlay.reload_view_with_story(story)
        @parent_shop_basic_overlay.hidden = !@parent_shop_basic_overlay.hidden?
      end
    end
  end

end
