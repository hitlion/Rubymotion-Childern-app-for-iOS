class ShopPremiumCell < UICollectionViewCell

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
    return if element.document.nil?

    @element = element

    view = UIButton.alloc.initWithFrame(self.bounds)
    view.addTarget(self, action: "cell_pressed:", forControlEvents: UIControlEventTouchUpInside)
    view.backgroundColor = rmq.color.babbo_orange
    view.tag = element.object_id

    image = UIImageView.alloc.initWithFrame(CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
    image.image = UIImage.imageWithData(element.asset_data(element.document.thumbnail))

    layer = UIImageView.alloc.initWithFrame(CGRectMake(0, 0, 0.75 * view.frame.size.width, 0.33 * view.frame.size.height ))
    layer.image = UIImage.imageNamed("cell_layer")

    label = UILabel.alloc.initWithFrame(CGRectMake(0, 0, layer.frame.size.width, 0.5 * layer.frame.size.height))
    label.text = element.document.branch_name
    label.textColor = UIColor.blackColor
    label.font = UIFont.fontWithName(TTUtil.get_font_standard(:regular), size: TTUtil.get_font_size(:large))
    label.textAlignment = UITextAlignmentLeft


    view.addSubview(image)
    view.addSubview(layer)
    view.addSubview(label)

    self.subviews.each do |s|
      s.removeFromSuperview
    end

    self.addSubview(view)
  end

  ##
  # Called if the user pressed the right button of the cell
  # than call the delegate method with the params self (this collection view cell) and the button element
  # @param source [UIButton] the pressed cell's button
  def cell_pressed (source)
    @delegate.shopPremiumCell(self, buttonPressed: source) if @delegate.respond_to? 'shopPremiumCell:buttonPressed:'
  end

end