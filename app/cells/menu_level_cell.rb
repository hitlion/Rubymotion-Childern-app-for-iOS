class MenuLevelCell < UICollectionViewCell

  attr_accessor :delegate, :element

  def initWithFrame(frame)
    super(frame)
    @delegate = self
    @babbo_orange = UIColor.colorWithRed(249.0/255.0, green: 188.0/255.0, blue: 52.0/255.0, alpha:1.0)
    self
  end

  def make_cell(element)

    @element = element

    return if(@element.nil?)

    view = UIButton.alloc.initWithFrame(self.bounds)
    view.addTarget(self, action: "cell_pressed:", forControlEvents: UIControlEventTouchUpInside)
    view.backgroundColor = UIColor.clearColor
    view.tag = element.object_id

    imageSize = CGSizeMake(view.frame.size.width, (view.frame.size.width / 4.0) * 3 )
    image = UIImageView.alloc.initWithFrame(CGRectMake(0, 0, imageSize.width, imageSize.height))
    image.image = UIImage.imageWithData(element.asset_data(element.document.thumbnail))

    name = UILabel.alloc.initWithFrame(CGRectMake(0, image.frame.size.height,
                                                  view.frame.size.width, view.frame.size.height / 8.0))
    name.backgroundColor = UIColor.clearColor
    name.text = element.document.set_name
    name.font = UIFont.fontWithName("Enriqueta-Regular", size:17)
    name.textAlignment = UITextAlignmentLeft
    name.textColor = @babbo_orange

    date = UILabel.alloc.initWithFrame(CGRectMake(0, image.frame.size.height + name.frame.size.height,
                                                   view.frame.size.width, view.frame.size.height / 8.0))
    date.backgroundColor = UIColor.clearColor

    time = Time.at(NSDate.dateWithNaturalLanguageString(element.document.timestamp))
    date.text = time.strftime("%d. %B %Y").to_s
    date.font = UIFont.fontWithName("Enriqueta-Regular", size:17)
    date.textAlignment = UITextAlignmentLeft

    view.addSubview(image)
    view.addSubview(name)
    view.addSubview(date)

    self.subviews.each do |s|
      s.removeFromSuperview
    end

    self.addSubview(view)
  end

  def cell_pressed (source)
    if(@delegate != self)
      @delegate.send('menuLevelCell:buttonPressed:', self, source)
    end
  end

end