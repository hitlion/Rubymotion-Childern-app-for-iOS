module ShopViewModule
  attr_reader :top_view_height, :bottom_view_height, :premium_stories,
              :basic_stories, :all_stories, :delegate

  CELL_IDENTIFIER = 'Cell'
  ##
  # Override this method to re-design this module
  # Copy the following parts and change the standard values
  # If this methods inst used than the layout used this standard values
  # @init = true is important, without this the values will be overridden with the
  # standard values again
  # @top_view_height    = 0.5
  # @bottom_view_height = 0.5
  #
  # @delegate           = delegate
  # @init = true
  def init_view_with_delegate(delegate)

    @top_view_height    = 0.5
    @bottom_view_height = 0.5

    @delegate           = delegate


    @init = true
  end

  def build_view

    @cells  = {}

    NSNotificationCenter.defaultCenter.removeObserver(self)

    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector: 'update_thumnail:',
                                                   name: 'ShopObjectThumbnailUpdated',
                                                   object: nil)
    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector: 'reload_shop_objects:',
                                                   name: 'ShopBundleUpdated',
                                                   object: nil)
    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector: 'shop_request_failed:',
                                                   name: 'ShopRequestFailed',
                                                   object: nil)

    init_view_with_delegate(WeakRef.new(self)) if @init.nil? || !@init

    add_loading_label
    add_premium_scroll_view
    add_basic_scroll_view

    if(device.iphone? && self.class == SmartphoneShopView)
      self.contentSize = CGSizeMake(self.frame.size.width,
                                    (@top_view_height + @bottom_view_height) * self.frame.size.height)
    end

    #pre-load shop
    BabboShop.get
  end

  ##
  # adds the premium story scoll view
  def add_premium_scroll_view

    layout = UICollectionViewFlowLayout.alloc.init
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal

    frame = CGRectMake(0, 0, self.frame.size.width, @top_view_height * self.frame.size.height)

    @premium_collection_view = UICollectionView.alloc.initWithFrame(frame, collectionViewLayout: layout)
    @premium_collection_view.dataSource = self
    @premium_collection_view.delegate = self

    height = @premium_collection_view.frame.size.height
    width  = (4 * height) / 3
    size = CGSizeMake(width, height)

    layout.itemSize = size

    @premium_collection_view.contentInset = UIEdgeInsetsMake(0, 0 * @premium_collection_view.frame.size.width,
                                                             0, 0 * @premium_collection_view.frame.size.width)

    @premium_collection_view.registerClass(ShopPremiumCell, forCellWithReuseIdentifier: CELL_IDENTIFIER)
    @premium_collection_view.backgroundColor = UIColor.clearColor
    @premium_collection_view.hidden = true

    self.addSubview(@premium_collection_view)
  end


  ##
  # adds the premium story scoll view
  def add_loading_label
    frame = CGRectMake(0, 0, self.frame.size.width, @top_view_height * self.frame.size.height)

    @info_label = UILabel.alloc.initWithFrame(frame)
    @info_label.text = 'Bitte warten, unser Shop wird gerade geladen...'
    @info_label.textColor = UIColor.blackColor
    device.ipad? ? @info_label.font = rmq.font.pad_large : @info_label.font = rmq.font.phone_large
    @info_label.textAlignment = UITextAlignmentCenter

    self.addSubview(@info_label)
  end

  ##
  # adds basic story collection scroll view
  def add_basic_scroll_view
    frame = CGRectMake(0, @top_view_height * self.frame.size.height,
                       self.frame.size.width, @bottom_view_height * self.frame.size.height)
    @basic_view = AdvancedCollectionView.alloc.init_with_frame(frame, cellType: ShopBasicCell,
                                                               numOfVisibleElements: 4, delegate: WeakRef.new(self),
                                                               headerText: "Kostenlose Stories")
    @basic_view.reload_data(@basic_stories)
    self.addSubview(@basic_view)
  end

  ##
  # Reload the data for all views
  def reload_data
    if(@all_stories.nil?)
      build_story_list
    end

    return unless @all_stories

    @premium_collection_view.reloadData
    @basic_view.reload_data(@basic_stories)

    if(@all_stories.length < 1)
      @info_label.text = 'Bitte warten, unser Shop wird gerade geladen...'
      @info_label.hidden = false
    else
      if(@premium_stories == [] && @basic_stories == [])
        @info_label.text = 'Keine weiteren Inhalte verfügbar, mehr ist auf dem Weg!'
        @info_label.hidden = false
      else
        @info_label.hidden = true
      end
    end

    @premium_collection_view.hidden = !@info_label.hidden?
  end

  def hide
    self.hidden = true
  end

  def show
    self.reload_data
    self.hidden = false
  end

  ##
  #
  def build_story_list
    @all_stories = BabboShop.get.get_all_products
    @premium_stories = BabboShop.get.get_premium_products
    @basic_stories = BabboShop.get.get_basic_products
  end

  def shopPremiumCell(cell, buttonPressed: button)
    path = @premium_collection_view.indexPathForCell(cell)
    @premium_collection_view.scrollToItemAtIndexPath(path,
                                                     atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally, animated:true)

    id  = button.tag
    story = @all_stories.find {|e| e.object_id == id}

    @delegate.tabletShopView(WeakRef.new(self), cell: cell, storyObject: story) if @delegate.respond_to? 'tabletShopView:cell:storyObject:'
  end

  ##
  # AdvancedColletionView instance methods
  # @param view [AdvancedCollectionView]
  # @param cell [UICollectionViewCell]
  # @param button [UIButton]
  def advancedCollectionView(view, cellPressed:cell, buttonObj:button)
    if(view == @basic_view)
      id  = button.tag
      story = @all_stories.find {|e| e.object_id == id}

      @delegate.tabletShopView(WeakRef.new(self), cell: cell, storyObject: story) if @delegate.respond_to? 'tabletShopView:cell:storyObject:'
    end
  end

  def advancedCollectionView(view, didEndDisplayingCell:cell, forItemAtIndexPath: path)
    if view == @basic_view
      Dispatch::Queue.concurrent.async do
        clear_chache(cell.element)
      end
    end
  end

  def advancedCollectionView(view, willDisplayCell:cell, forItemAtIndexPath: path)
    if view == @basic_view
      Dispatch::Queue.concurrent.async do
        cell.element.screenshots
      end
    end
  end

  # UICollectionView Instance Methods
  def collectionView(view, numberOfItemsInSection:section)
    if(view == @premium_collection_view)
      return @premium_stories.length if(!@premium_stories.nil?)
    end

    return 0
  end

  def collectionView(view, cellForItemAtIndexPath:path)
    cell = view.dequeueReusableCellWithReuseIdentifier(CELL_IDENTIFIER, forIndexPath: path)

    if(view == @premium_collection_view)
      story = @premium_stories[path.row]
      cell.delegate = WeakRef.new(self)
      cell.make_cell(story)
    end

    @cells = {} unless @cells
    @cells[story.productIdentifier] = path

    cell
  end

  def collectionView(view, didEndDisplayingCell:cell, forItemAtIndexPath: path)
    if view == @premium_collection_view
      Dispatch::Queue.concurrent.async do
        clear_chache(cell.element)
      end
    end
  end

  def collectionView(view, willDisplayCell:cell, forItemAtIndexPath: path)
    if view == @premium_collection_view
      Dispatch::Queue.concurrent.async do
        cell.element.screenshots
      end
    end
  end

  def clear_chache(bundle)
    bundle.clear_chache
  end

  def update_thumnail(notification)
    Dispatch::Queue.main.async do
      reload_data
    end
  end

  def reload_shop_objects(notification)
    Dispatch::Queue.main.async do
      build_story_list
      reload_data
    end
  end

  def shop_request_failed(notification)
    app.alert(title: "Verbindung zum Shop leider nicht möglich!", message: notification.userInfo[:description], actions: ['OK'])
  end

  def restore_purchases
    BabboShop.get.restore_purchases
  end
end