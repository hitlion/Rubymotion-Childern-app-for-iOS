class SmartphoneMenuView < UIScrollView

  attr_reader   :grouped_stories, :all_stories, :delegate

  ##
  # Constants to define the heigth of the top and
  # the bottom part of this view. The sum of both
  # values can be greater 1
  TopViewHeight         = 0.75
  BottomViewHeight      = 0.75

  ##
  # Identifier for all cells
  CellIdentifier = 'Cell'

  def init_with_frame(frame, delegate: delegate)
    self.initWithFrame(frame)

    @delegate = delegate

    build_story_list

    build_view

    @bottomOffset = CGPointMake(0,self.contentSize.height - self.bounds.size.height)
    self
  end

  def build_view

    add_story_scroll_view
    add_level_scroll_view
    add_tips_and_tricks_view

    self.contentSize = CGSizeMake(self.frame.size.width, (TopViewHeight + BottomViewHeight) * self.frame.size.height)
  end

  ##
  # adds the story scoll view
  def add_story_scroll_view

    story_layout = UICollectionViewFlowLayout.alloc.init
    story_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal

    frame = CGRectMake(0, 0, self.frame.size.width, TopViewHeight * self.frame.size.height)

    @story_collection_view = UICollectionView.alloc.initWithFrame(frame, collectionViewLayout: story_layout)
    @story_collection_view.dataSource = self
    @story_collection_view.delegate = self

    height = @story_collection_view.frame.size.height
    width  = (4 * height) / 3
    size = CGSizeMake(width, height)

    story_layout.itemSize = size

    @story_collection_view.contentInset = UIEdgeInsetsMake(0, 0 * @story_collection_view.frame.size.width,
                                                           0, 0 * @story_collection_view.frame.size.width)

    @story_collection_view.registerClass(MenuStoryCell, forCellWithReuseIdentifier: CellIdentifier)
    @story_collection_view.backgroundColor = UIColor.clearColor

    self.addSubview(@story_collection_view)
  end

  ##
  # adds tips and tricks collection view
  def add_tips_and_tricks_view
    @tips_list = TipsBundle.alloc.init
    frame = CGRectMake(0, TopViewHeight * self.frame.size.height,
                       self.frame.size.width, BottomViewHeight * self.frame.size.height)
    @tips_view = AdvancedCollectionView.alloc.init_with_frame(frame, cellType: MenuTipsCell,
                                                              numOfVisibleElements: 1, delegate: self,
                                                              headerText: "Tipps und Tricks")
    @tips_view.reload_data(@tips_list)
    self.addSubview(@tips_view)
  end

  ##
  # adds level collection scroll view
  def add_level_scroll_view
    frame = CGRectMake(0, TopViewHeight * self.frame.size.height,
                       self.frame.size.width, BottomViewHeight * self.frame.size.height)
    @level_view = AdvancedCollectionView.alloc.init_with_frame(frame, cellType: MenuLevelCell,
                                                               numOfVisibleElements: 4, delegate: self,
                                                               headerText: "Erstellte Stories")
    @level_view.reload_data(@grouped_stories[0])
    @level_view.hidden = true
    self.addSubview(@level_view)
  end

  ##
  # Reload the date for all views
  # and rebuild them
  def reload_data
    build_story_list
    build_view
  end

  ##
  # Get the whole story list a build a second one, grouped by the
  # document_id
  def build_story_list
    @all_stories = StoryBundle.bundles.select { |b| b.valid? }
    stories = {}

    @all_stories.each do |s|
      stories[s.document.document_id] ||= []
      stories[s.document.document_id] << s
    end

    @grouped_stories = stories.keys.map { |k| stories[k] }
  end

  ##
  # more was pressed (left button in menu story view cell)
  # rebuild the level list and open the level collection view
  # hide the tipps and tricks section
  # @param list [StoryList] a list with stories, that have the same document_id
  # @param path [NSIndexPath] the path for the clicked story cell
  def more(list, path: path)
    @level_view.reload_data(list)

    @level_view.hidden = false
    @tips_view.hidden = true

    @story_collection_view.scrollToItemAtIndexPath(path,
                                                   atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally,
                                                   animated:true)
    self.setContentOffset(@bottomOffset, animated: true)
  end

  ##
  # less was pressed (left button in menu story view cell)
  # open the tipss and tricks collection view
  # hide the level list section
  def less(story)
    @level_view.hidden = true
    @tips_view.hidden = false
  end
  ##
  # MenuStoryCell instance method
  # @param cell [UICollectionViewCell]
  # @param source [UIButton]
  def menuStoryCell(cell, rightButtonPressed: source)
    id  = source.tag
    story = @all_stories.find {|e| e.object_id == id}
    @delegate.tabletMenuView(self, storyObject: story) if @delegate.respond_to? 'tabletMenuView:storyObject:'
  end

  ##
  # MenuStoryCell instance method
  # @param cell [UICollectionViewCell]
  # @param source [UIButton]
  def menuStoryCell(cell, leftButtonPressed: source)
    id  = source.tag

    story_level_list = @grouped_stories.find {|e| e[0].object_id == id}
    index = @grouped_stories.index (story_level_list)
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
  # AdvancedColletionView instance methods
  # @param view [AdvancedCollectionView]
  # @param cell [UICollectionViewCell]
  # @param button [UIButton]
  def advancedCollectionView(view, cellPressed:cell, buttonObj:button)
    if(view == @level_view)
      id  = button.tag
      story = @all_stories.find {|e| e.object_id == id}
      @delegate.tabletMenuView(self, storyObject: story) if @delegate.respond_to? 'tabletMenuView:storyObject:'
    end
  end

  # UICollectionView Instance Methods
  def collectionView(view, numberOfItemsInSection:section)
    if(view == @story_collection_view)
      return @grouped_stories.length if(!@grouped_stories.nil?)
    end

    return 0
  end

  def collectionView(view, cellForItemAtIndexPath:path)
    cell = view.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: path)

    if(view == @story_collection_view)
      list = @grouped_stories[path.row]
      cell.delegate = self
      cell.make_cell(list[0])
    end

    cell
  end
end