module MenuViewModule
  attr_reader :top_view_height, :bottom_view_height, :grouped_stories,
              :all_stories, :delegate

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

    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector: 'bundlesChanges:',
                                                   name: 'BabboBundleChanged',
                                                   object: nil)

    @top_view_height    = 0.5
    @bottom_view_height = 0.5

    @delegate           = delegate

    @init = true
  end

  def build_view

    init_view_with_delegate(self) if @init.nil? || !@init

    build_story_list

    add_story_scroll_view
    add_level_scroll_view
    add_tips_and_tricks_view

    if(device.iphone? && self.class == SmartphoneMenuView)
      self.contentSize = CGSizeMake(self.frame.size.width,
                                    (@top_view_height + @bottom_view_height) * self.frame.size.height)
    end
  end

  ##
  # adds the story scoll view
  def add_story_scroll_view

    story_layout = UICollectionViewFlowLayout.alloc.init
    story_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal

    frame = CGRectMake(0, 0, self.frame.size.width, @top_view_height * self.frame.size.height)

    @story_collection_view = UICollectionView.alloc.initWithFrame(frame, collectionViewLayout: story_layout)
    @story_collection_view.dataSource = self
    @story_collection_view.delegate = self

    height = @story_collection_view.frame.size.height
    width  = (4 * height) / 3
    size = CGSizeMake(width, height)

    story_layout.itemSize = size

    @story_collection_view.contentInset = UIEdgeInsetsMake(0, 0 * @story_collection_view.frame.size.width,
                                                           0, 0 * @story_collection_view.frame.size.width)

    @story_collection_view.registerClass(MenuStoryCell, forCellWithReuseIdentifier: CELL_IDENTIFIER)
    @story_collection_view.backgroundColor = UIColor.clearColor

    self.addSubview(@story_collection_view)
  end

  ##
  # adds tips and tricks collection view
  def add_tips_and_tricks_view
    tips_list = TipsBundle.alloc.init
    frame = CGRectMake(0, @top_view_height * self.frame.size.height,
                       self.frame.size.width, @bottom_view_height * self.frame.size.height)
    @tips_view = AdvancedCollectionView.alloc.init_with_frame(frame, cellType: MenuTipsCell,
                                                              numOfVisibleElements: 1, delegate: self,
                                                              headerText: "Tipps und Tricks")
    @tips_view.reload_data(tips_list.get)
    self.addSubview(@tips_view)
  end

  ##
  # adds level collection scroll view
  def add_level_scroll_view
    frame = CGRectMake(0, @top_view_height * self.frame.size.height,
                       self.frame.size.width, @bottom_view_height * self.frame.size.height)
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

    @grouped_stories.each_with_index do |s,k|
      s.sort_by! { |k| k.document.timestamp}
      s.reverse!
    end

    @grouped_stories.sort_by! { |s| s[0].document.timestamp}
    @grouped_stories.reverse!
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

    if(device.iphone? && self.class == SmartphoneMenuView)
      @bottomOffset = CGPointMake(0,self.contentSize.height - self.bounds.size.height)
      self.setContentOffset(@bottomOffset, animated: true)
    end
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
    #todo ändern!!!! Name schlecht und alt
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

  def advancedCollectionView(view, didEndDisplayingCell:cell, forItemAtIndexPath: path)
    if view == @level_view
      Dispatch::Queue.concurrent.async do
        clear_chache(cell.element)
      end
    end
  end

  def advancedCollectionView(view, willDisplayCell:cell, forItemAtIndexPath: path)
    if view == @level_view
      Dispatch::Queue.concurrent.async do
        cell.element.document.screenshots
      end
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
    cell = view.dequeueReusableCellWithReuseIdentifier(CELL_IDENTIFIER, forIndexPath: path)

    if(view == @story_collection_view)
      list = @grouped_stories[path.row]
      cell.delegate = self
      cell.make_cell(list[0])
    end

    cell
  end

  def collectionView(view, didEndDisplayingCell:cell, forItemAtIndexPath: path)
    if view == @story_collection_view
      Dispatch::Queue.concurrent.async do
        clear_chache(cell.element)
      end
    end
  end

  def collectionView(view, willDisplayCell:cell, forItemAtIndexPath: path)
    if view == @story_collection_view
      Dispatch::Queue.concurrent.async do
        cell.element.document.screenshots
      end
    end
  end

  def clear_chache(bundle)
    bundle.document.clear_chache
  end

  def bundlesChanges(notification)
    less(nil)
    reload_data
    @story_collection_view.reloadData
  end

end