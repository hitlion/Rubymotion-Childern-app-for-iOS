class MenuTipsCell < UICollectionViewCell

  attr_accessor :element, :delegate

  def initWithFrame(frame)
    super(frame)
    @delegate = self

    if(device.ipad?)
      @font_fac = 1.5
    else
      @font_fac = 1
    end

    self
  end

  ##
  # Build the cell with the data from the given element
  # @param element [TipsItem] The Story for filling the data of this cell
  def make_cell(element)

    @element = element

    return if(@element.nil?)

    view = UIView.alloc.initWithFrame(CGRectMake(0,0,self.frame.size.width, self.frame.size.height))
    view.backgroundColor = UIColor.whiteColor

    label = UILabel.alloc.initWithFrame(CGRectMake(0.0 * view.frame.size.width, 0,
                                                   0.55 * view.frame.size.width, 0.15  * view.frame.size.height))
    label.text = element.header
    label.font = UIFont.fontWithName("Enriqueta-Bold", size:15 * @font_fac)
    label.textAlignment = UITextAlignmentLeft
    label.textColor = rmq.color.babbo_orange

    text_view = UITextView.alloc.initWithFrame(CGRectMake(0.0 * view.frame.size.width, 0.2 * view.frame.size.height,
                                                         0.55 * view.frame.size.width, 0.75 * view.frame.size.height ))
    text_view.font = UIFont.fontWithName("Enriqueta-Regular", size:10 * @font_fac)
    text_view.textAlignment = UITextAlignmentLeft

    text_view.text = element.text

    image = UIImageView.alloc.initWithFrame(CGRectMake(0.6 * view.frame.size.width,0,0.40 * view.frame.size.width, view.frame.size.height))
    image.image = element.image

    view.addSubview(text_view)
    view.addSubview(image)
    view.addSubview(label)

    self.subviews.each do |s|
      s.removeFromSuperview
    end

    self.addSubview(view)
  end
end