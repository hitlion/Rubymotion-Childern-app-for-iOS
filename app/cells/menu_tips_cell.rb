class MenuTipsCell < UICollectionViewCell

  attr_accessor :element

  def initWithFrame(frame)
    super(frame)
    @delegate = self
    @babbo_orange = UIColor.colorWithRed(249.0/255.0, green: 188.0/255.0, blue: 52.0/255.0, alpha:1.0)
    self
  end

  def make_cell(element)

    @element = element

    return if(@element.nil?)

    view = UIView.alloc.initWithFrame(CGRectMake(0,0,self.frame.size.width, self.frame.size.height))
    view.backgroundColor = UIColor.whiteColor

    label = UILabel.alloc.initWithFrame(CGRectMake(0.0 * view.frame.size.width, 0,
                                                   0.55 * view.frame.size.width, 0.15  * view.frame.size.height))
    label.text = element.header
    label.font = UIFont.fontWithName("Enriqueta-Bold", size:25)
    label.textAlignment = UITextAlignmentLeft
    label.textColor = @babbo_orange

    textView = UITextView.alloc.initWithFrame(CGRectMake(0.0 * view.frame.size.width, 0.2 * view.frame.size.height,
                                                         0.55 * view.frame.size.width, 0.75 * view.frame.size.height ))
    textView.font = UIFont.fontWithName("Enriqueta-Regular", size:17)
    textView.textAlignment = UITextAlignmentLeft

    textView.text = element.text

    image = UIImageView.alloc.initWithFrame(CGRectMake(0.6 * view.frame.size.width,0,0.35 * view.frame.size.width, view.frame.size.height))
    image.image = element.image

    view.addSubview(textView)
    view.addSubview(image)
    view.addSubview(label)

    self.subviews.each do |s|
      s.removeFromSuperview
    end

    self.addSubview(view)
  end
end