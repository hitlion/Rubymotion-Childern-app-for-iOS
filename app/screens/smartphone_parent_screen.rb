class SmartphoneParentScreen < PM::Screen

  NavbarHeight          = 0.150 # * screen_height
  MiddleViewHeight      = 0.700 # * screen_height
  TabbarHeight          = 0.150 # * screen_height

  CellIdentifier = 'Cell'

  include OrientationModule

  def will_appear

    @parentmenu = UIView.alloc.initWithFrame(CGRectMake(0 ,0, device.screen_width, device.screen_height))
    @parentmenu.backgroundColor = UIColor.whiteColor

    @choosen_story_index ||= 0

    add @parentmenu

    setup_nav_bar
    setup_menu_view
    setup_shop_view
    #TODO: activate tab abr
    #setup_tab_bar
    setup_options
    setup_overlay
  end

  ##
  # add a own navigation bar
  def setup_nav_bar
    frame = CGRectMake(0, 0, @parentmenu.frame.size.width, NavbarHeight * @parentmenu.frame.size.height)
    @navbar = SmartphoneNavbarView.alloc.init_with_frame(frame, titleText: "Alle Spiele", delegate: WeakRef.new(self))
    @parentmenu.addSubview(@navbar)
  end

  def setup_menu_view
    frame = CGRectMake(0, NavbarHeight * @parentmenu.frame.size.height,
                       @parentmenu.frame.size.width, MiddleViewHeight * @parentmenu.frame.size.height)
    @menu_view = SmartphoneMenuView.alloc.init_with_frame(frame, delegate: WeakRef.new(self))
    @parentmenu.addSubview(@menu_view)
  end

  def setup_shop_view
    frame = CGRectMake(0, NavbarHeight * @parentmenu.frame.size.height,
                       @parentmenu.frame.size.width, MiddleViewHeight * @parentmenu.frame.size.height)
    @shop_view = SmartphoneShopView.alloc.init_with_frame(frame, delegate: WeakRef.new(self))
    @shop_view.hidden = true
    @parentmenu.addSubview(@shop_view)
  end

  ##
  # adds the tab bar at the bottom of the screen
  def setup_tab_bar
    frame = CGRectMake(0, (NavbarHeight + MiddleViewHeight) *  @parentmenu.frame.size.height,
                       @parentmenu.frame.size.width, TabbarHeight * @parentmenu.frame.size.height)
    @tab_bar = SmartphoneTabbarView.alloc.init_with_frame(frame, delegate: WeakRef.new(self))
    @parentmenu.addSubview(@tab_bar)
  end

  ##
  # add options view
  def setup_options
    @options_view = rmq(self.view).append!(OptionView)
    @options_view.hide
    @options_view.delegate = WeakRef.new(self)
    @parentmenu.append(@options_view)
  end

  def setup_overlay
    frame = CGRectMake(0, 0, device.screen_width, device.screen_height)
    @overlay_view ||= OverlayView.alloc.initWithFrame(frame)
    @overlay_view.hide
    @parentmenu.addSubview(@overlay_view)
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

    if (button_id == 0)
      @shop_view.hide
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
        @shop_view.show
        @menu_view.hidden = true
        @navbar.show_back_button
        @options_view.hide
      end
    elsif (button_id == 3)
      if @options_view.hidden?
        @options_view.show
      else
        @options_view.hide
      end
      @shop_view.hide
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
      #@parent_menu_overlay.reload_view_with_story(story)
      @overlay_view.show_overlay_type(:menu_standard, data: story)
    end
  end

  ##
  # instance method for TabletShopView, called if a cell (story) is pressed
  # @param view [TabletMenuView] The tabletMenuView object
  # @param cell [UICollectioViewCell] The pressed cell
  # @param source [UIButton] The pressed button object
  def tabletShopView(view, cell: cell, storyObject: story)
    if(cell.class == ShopPremiumCell)
      @overlay_view.show_overlay_type(:shop_premium, data: story)
    elsif(cell.class == ShopBasicCell)
      @overlay_view.show_overlay_type(:shop_basic, data: story)
    end
  end

end
