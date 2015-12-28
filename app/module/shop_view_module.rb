module ShopViewModule
  attr_reader :top_view_height, :bottom_view_height, :premium_stories,
              :basic_stories, :all_stories, :delegate


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

    init_view_with_delegate(self) if @init.nil? || !@init

    build_story_list

    add_premium_scroll_view
    add_basic_scroll_view

    if(device.iphone? && self.class == SmartphoneShopView)
      self.contentSize = CGSizeMake(self.frame.size.width,
                                    (@top_view_height + @bottom_view_height) * self.frame.size.height)
    end
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

    self.addSubview(@premium_collection_view)
  end

  ##
  # adds basic story collection scroll view
  def add_basic_scroll_view
    frame = CGRectMake(0, @top_view_height * self.frame.size.height,
                       self.frame.size.width, @bottom_view_height * self.frame.size.height)
    @basic_view = AdvancedCollectionView.alloc.init_with_frame(frame, cellType: ShopBasicCell,
                                                               numOfVisibleElements: 4, delegate: self,
                                                               headerText: "Basic Stories")
    @basic_view.reload_data(@basic_stories)
    self.addSubview(@basic_view)
  end

  ##
  # Reload the date for all views
  # and rebuild them
  def reload_data
    build_story_list
    build_view
  end

  ##
  #
  def build_story_list
    @all_stories = StoryBundle.bundle_list
    @premium_stories = StoryBundle.bundle_list
    @basic_stories = StoryBundle.bundle_list
  end

  def shopPremiumCell(cell, buttonPressed: button)
    path = @premium_collection_view.indexPathForCell(cell)
    @premium_collection_view.scrollToItemAtIndexPath(path,
                                                     atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally, animated:true)

    id  = button.tag
    story = @all_stories.find {|e| e.object_id == id}

    @delegate.tabletShopView(self, cell: cell, storyObject: story) if @delegate.respond_to? 'tabletShopView:cell:storyObject:'
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

      @delegate.tabletShopView(self, cell: cell, storyObject: story) if @delegate.respond_to? 'tabletShopView:cell:storyObject:'
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
      cell.delegate = self
      cell.make_cell(story)
    end

    cell
  end
end