class ShopBasicCell < UICollectionViewCell

  attr_accessor :delegate, :element

  def initWithFrame(frame)
    super(frame)
    @delegate = self
    self
  end

  ##
  # Build the cell with the data from the given element
  # @param element [Story] The Story for filling the data of this cell
  def make_cell(element)

    return if element.nil?

    @element = element

    view = UIButton.alloc.initWithFrame(self.bounds)
    view.addTarget(self, action: "cell_pressed:", forControlEvents: UIControlEventTouchUpInside)
    view.backgroundColor = UIColor.clearColor
    view.tag = element.object_id

    image_size = CGSizeMake(view.frame.size.width, (view.frame.size.width / 4.0) * 3 )
    image = UIImageView.alloc.initWithFrame(CGRectMake(0, 0, image_size.width, image_size.height))
    image.image = element.thumbnail

    name = UILabel.alloc.initWithFrame(CGRectMake(0, image.frame.size.height,
                                                  view.frame.size.width, view.frame.size.height / 8.0))
    name.backgroundColor = UIColor.clearColor
    name.text = element.set_name
    name.font = UIFont.fontWithName(TTUtil.get_font_standard(:regular), size: TTUtil.get_font_size(:small))
    name.textAlignment = UITextAlignmentLeft
    name.textColor = rmq.color.babbo_orange

    #date = UILabel.alloc.initWithFrame(CGRectMake(0, image.frame.size.height + name.frame.size.height,
      #                                            view.frame.size.width, view.frame.size.height / 8.0))
    #date.backgroundColor = UIColor.clearColor

    #time = Time.at(NSDate.dateWithNaturalLanguageString(element.document.timestamp))
    #date.text = time.strftime("%d. %B %Y").to_s
    #date.font = UIFont.fontWithName(TTUtil.get_font_standard(:regular), size: TTUtil.get_font_size(:small))
    #date.textAlignment = UITextAlignmentLeft

    view.addSubview(image)
    view.addSubview(name)
    #view.addSubview(date)

    self.subviews.each do |s|
      s.removeFromSuperview
    end

    self.addSubview(view)
  end

  ##
  # Called if the user pressed on one cell
  # than call the delegate method with the params self (this collection view cell) and the button element
  # @param source [UIButton] the pressed cell's button the whole cell is the button
  def cell_pressed (source)
    @delegate.shopBasicCell(self, buttonPressed: source) if @delegate.respond_to? 'shopBasicCell:buttonPressed:'
  end

end
