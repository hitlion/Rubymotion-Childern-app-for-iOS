class AdvancedCollectionView < UIView

  attr_reader :visible_elements, :cell_type, :elements, :delegate, :header_text

  ###
  # Constants to design the layout.
  # The height divide in the following way, (
  # TopViewHeightFak + BottomViewHeightFak) * Height = Height.
  # TopViewHeightFak + BottomViewHeightFak must be 1
  #
  # The Width of the BottomView is divided in
  # Width = ScrollButtonWidthFak * Width
  # + CollectionViewWidthFak * Width
  # + ScrollButtonWidthFak * Width
  # Also 2 * ScrollButtonWidthFak + CollectionViewWidthFak must be 1
  TopViewHeightFac       = 0.20
  BottomViewHeightFac    = 0.80
  ScrollButtonWidthFac   = 0.075
  CollectionViewWidthFac = 0.85

  CellIdentifier = 'Cell'

  ##
  # Init the advanced collection view
  # @param frame [CGRect] The whole view's frame
  # @param cellType [Class] The class for the collection view cells (Subclass of UICollectionViewCell)
  # @param visibleElements [Integer] The number of visible cells in the collection view
  # @param delegate [class] The delegate class
  # @param headerText [String] The text for the header
  def init_with_frame(frame, cellType: cellType, numOfVisibleElements: visibleElements, delegate: delegate, headerText: headerText)
    self.initWithFrame(frame)

    @cell_type        = cellType
    @visible_elements = visibleElements
    @delegate         = delegate
    @header_text      = headerText
    @cells            = {}

    build_view

    self
  end

  ##
  # build the whole view
  def build_view
    ####
    # Define the top view and add it as subview of self
    frame = CGRectMake(0.0 * self.frame.size.width, 0.0 * self.frame.size.height,
                       1.0 * self.frame.size.width, TopViewHeightFac * self.frame.size.height)
    top_view    = UIView.alloc.initWithFrame(frame)
    self.addSubview(top_view)

    ###
    # Define top header label
    frame = CGRectMake(ScrollButtonWidthFac * top_view.frame.size.width, 0.0 * top_view.frame.size.height,
                       CollectionViewWidthFac * top_view.frame.size.width, 0.95 * top_view.frame.size.height)
    header_label = UILabel.alloc.initWithFrame(frame)
    header_label.text = @header_text
    header_label.textColor = UIColor.blackColor
    device.ipad? ? header_label.font = rmq.font.pad_large : header_label.font = rmq.font.phone_large
    header_label.textAlignment = UITextAlignmentLeft
    top_view.addSubview(header_label)

    ###
    # Define top header underline
    frame = CGRectMake(ScrollButtonWidthFac * top_view.frame.size.width, 1.0 * top_view.frame.size.height - 1,
                       CollectionViewWidthFac * top_view.frame.size.width, 1)
    header_line = UIView.alloc.initWithFrame(frame)
    header_line.backgroundColor = rmq.color.babbo_line_grey
    top_view.addSubview(header_line)

    ####
    # Define the bottom view and add it as subview of self
    frame = CGRectMake(0.0 * self.frame.size.width, TopViewHeightFac * self.frame.size.height,
                       1.0 * self.frame.size.width, BottomViewHeightFac * self.frame.size.height)
    bottom_view = UIView.alloc.initWithFrame(frame)
    self.addSubview(bottom_view)

    ###
    # Define scroll left button
    frame = CGRectMake(0.0 * bottom_view.frame.size.width, 0.0 * bottom_view.frame.size.height,
                       ScrollButtonWidthFac * bottom_view.frame.size.width, 1.0 * bottom_view.frame.size.height)
    scroll_button_left = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    scroll_button_left.frame = frame
    scroll_button_left.tintColor = rmq.color.babbo_button_grey
    scroll_button_left.setImage(UIImage.imageNamed("icons/arrow_left.png"), forState:UIControlStateNormal)
    scroll_button_left.addTarget(WeakRef.new(self), action: "scroll_button_pressed:", forControlEvents: UIControlEventTouchUpInside)
    scroll_button_left.tag = -1
    bottom_view.addSubview(scroll_button_left)

    ###
    # Define collection view
    collection_view_layout = UICollectionViewFlowLayout.alloc.init
    collection_view_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal

    frame = CGRectMake(ScrollButtonWidthFac * bottom_view.frame.size.width, 0.0 * bottom_view.frame.size.height,
                       CollectionViewWidthFac * bottom_view.frame.size.width, 1.0 * bottom_view.frame.size.height)
    @collection_view = UICollectionView.alloc.initWithFrame(frame, collectionViewLayout: collection_view_layout)
    @collection_view.dataSource = self
    @collection_view.delegate = self
    @collection_view.pagingEnabled = true

    minimumLineSpacing = 20  if(visible_elements >= 2)
    minimumLineSpacing = 0   if(visible_elements == 1)

    collection_view_layout.minimumLineSpacing = minimumLineSpacing
    width  = (@collection_view.frame.size.width - (@visible_elements - 1) * minimumLineSpacing) / @visible_elements

    if(width < 0.9 * @collection_view.frame.size.height)
      height = width
    else

      height = 0.9 * @collection_view.frame.size.height
      if(@cell_type == MenuLevelCell)
        width = height
      end
    end

    collection_view_layout.itemSize = CGSizeMake(width, height)

    @collection_view.contentInset = UIEdgeInsetsMake(0,0,0,0)
    @collection_view.backgroundColor = UIColor.clearColor
    @collection_view.registerClass(@cell_type, forCellWithReuseIdentifier: CellIdentifier)

    bottom_view.addSubview(@collection_view)

    ###
    # Define scroll right button
    frame = CGRectMake((ScrollButtonWidthFac + CollectionViewWidthFac) * bottom_view.frame.size.width,
                       0.0 * bottom_view.frame.size.height,
                       ScrollButtonWidthFac * bottom_view.frame.size.width, 1.0 * bottom_view.frame.size.height)
    scroll_button_right = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    scroll_button_right.frame = frame
    scroll_button_right.tintColor = rmq.color.babbo_button_grey
    scroll_button_right.setImage(UIImage.imageNamed("icons/arrow_right.png"), forState:UIControlStateNormal)
    scroll_button_right.addTarget(self, action: "scroll_button_pressed:", forControlEvents: UIControlEventTouchUpInside)
    scroll_button_right.tag = +1
    bottom_view.addSubview(scroll_button_right)
  end

  ##
  # Called if the user pressed one of the two scroll buttons
  # @param source [UIButton] the pressed scroll button
  def scroll_button_pressed (source)
    return if numberOfItems <= 0

    @visible_tip_cell ||= 0

    direction = source.tag
    row = @visible_tip_cell + direction

    if(row == @collection_view.numberOfItemsInSection(0))
      row = @collection_view.numberOfItemsInSection(0) - 1
    end

    if(row == -1)
      row = 0
    end

    @visible_tip_cell = row
    destination = NSIndexPath.indexPathForRow(row, inSection:0)
    @collection_view.scrollToItemAtIndexPath(destination, atScrollPosition:UICollectionViewScrollPositionLeft,
                                             animated:true)
  end

  def numberOfItems
    return @collection_view.numberOfItemsInSection(0)
  end
  ##
  # reload the collection view cells
  # @param elements [var] An Array with the data for the collection view cells
  def reload_data(elements)
    @elements = elements
    @collection_view.reloadData
  end

  ##
  # instance methods for MenuLevelCell
  # @param cell [MenuLevelCell] the pressed cell
  # @param source [UIButton] the pressed button object
  def menuLevelCell(cell, buttonPressed: source)
    if (@delegate.respond_to? 'advancedCollectionView:cellPressed:buttonObj:')
      @delegate.advancedCollectionView(WeakRef.new(self), cellPressed: cell, buttonObj: source)
    end
  end

  ##
  # instance methods for MenuLevelCell
  # @param cell [MenuLevelCell] the pressed cell
  # @param source [UIButton] the pressed button object
  def shopBasicCell(cell, buttonPressed: source)
    if (@delegate.respond_to? 'advancedCollectionView:cellPressed:buttonObj:')
      @delegate.advancedCollectionView(WeakRef.new(self), cellPressed: cell, buttonObj: source)
    end
  end

  # UICollectionView Instance Methods
  def collectionView(view, numberOfItemsInSection:section)
    return @elements.length if(!@elements.nil?)
    return 0
  end

  def collectionView(view, cellForItemAtIndexPath:path)
    cell = view.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: path)
    cell.make_cell(@elements[path.row])
    cell.delegate = WeakRef.new(self)
    item = @elements[path.row]
    if item.is_a?(ShopProduct) || item.is_a?(StoryBundle)
      identifier = item.productIdentifier
      @cells[identifier] = path if identifier
    end

    cell
  end

  def collectionView(view, didEndDisplayingCell:cell, forItemAtIndexPath:path)
    if (@delegate.respond_to? 'advancedCollectionView:didEndDisplayingCell:forItemAtIndexPath:')
      @delegate.advancedCollectionView(WeakRef.new(self), didEndDisplayingCell:cell, forItemAtIndexPath: path)
    end
  end

  def collectionView(view, willDisplayCell:cell, forItemAtIndexPath:path)
    if (@delegate.respond_to? 'advancedCollectionView:willDisplayCell:forItemAtIndexPath:')
      @delegate.advancedCollectionView(WeakRef.new(self), willDisplayCell:cell, forItemAtIndexPath: path)
    end
  end

  def reloadItemsWithIdentifier(identifier)
    return if identifier.nil?

    path = []
    path << @cells[identifier] if @cells[identifier]
    unless path.first.nil?
      @collection_view.reloadItemsAtIndexPaths(path)
    end

  end

end
