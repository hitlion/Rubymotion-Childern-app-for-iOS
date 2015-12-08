class TabletShopView < UIView
  attr_reader   :premium_stories, :basic_stories, :all_stories, :delegate

  ##
  # Constants to define the heigth of the top and
  # the bottom part of this view. The sum of both
  # values must be 1
  TopViewHeight         = 0.5
  BottomViewHeight      = 0.5

  ##
  # Identifier for all cells
  CellIdentifier = 'Cell'

  def init_with_frame(frame, delegate: delegate)
    self.initWithFrame(frame)

    @delegate = delegate

    build_story_list

    build_view

    self
  end

  def build_view
    add_premium_scroll_view
    add_basic_scroll_view
  end

  ##
  # adds the premium story scoll view
  def add_premium_scroll_view

    layout = UICollectionViewFlowLayout.alloc.init
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal

    frame = CGRectMake(0, 0, self.frame.size.width, TopViewHeight * self.frame.size.height)

    @premium_collection_view = UICollectionView.alloc.initWithFrame(frame, collectionViewLayout: layout)
    @premium_collection_view.dataSource = self
    @premium_collection_view.delegate = self

    height = @premium_collection_view.frame.size.height
    width  = (4 * height) / 3
    size = CGSizeMake(width, height)

    layout.itemSize = size

    @premium_collection_view.contentInset = UIEdgeInsetsMake(0, 0 * @premium_collection_view.frame.size.width,
                                                           0, 0 * @premium_collection_view.frame.size.width)

    @premium_collection_view.registerClass(ShopPremiumCell, forCellWithReuseIdentifier: CellIdentifier)
    @premium_collection_view.backgroundColor = UIColor.clearColor

    self.addSubview(@premium_collection_view)
  end

  ##
  # adds basic story collection scroll view
  def add_basic_scroll_view
    frame = CGRectMake(0, TopViewHeight * self.frame.size.height,
                       self.frame.size.width, BottomViewHeight * self.frame.size.height)
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

  def shopPremiumCell(cell, buttonPressed: source)
    path = @premium_collection_view.indexPathForCell(cell)
    @premium_collection_view.scrollToItemAtIndexPath(path,
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally, animated:true)
  end

  def advancedCollectionView(view, cellPressed:cell, buttonObj: source)

  end

  # UICollectionView Instance Methods
  def collectionView(view, numberOfItemsInSection:section)
    if(view == @premium_collection_view)
      return @premium_stories.length if(!@premium_stories.nil?)
    end

    return 0
  end

  def collectionView(view, cellForItemAtIndexPath:path)
    cell = view.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: path)

    if(view == @premium_collection_view)
      story = @premium_stories[path.row]
      cell.delegate = self
      cell.make_cell(story)
    end

    cell
  end
end