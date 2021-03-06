class MenuTipsCell < UICollectionViewCell

  attr_accessor :element, :delegate

  def initWithFrame(frame)
    super(frame)
    @delegate = self

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
                                                   0.55 * view.frame.size.width, 0.20  * view.frame.size.height))
    label.text = element.header
    device.ipad? ? label.font = rmq.font.pad_large_bold : label.font = rmq.font.phone_large_bold
    label.textAlignment = UITextAlignmentLeft
    label.textColor = rmq.color.babbo_orange

    text_view = UITextView.alloc.initWithFrame(CGRectMake(0.0 * view.frame.size.width, 0.2 * view.frame.size.height,
                                                         0.55 * view.frame.size.width, 0.70 * view.frame.size.height ))
    text_view.editable = false
    device.ipad? ? text_view.font = rmq.font.pad_medium : text_view.font = rmq.font.phone_medium
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