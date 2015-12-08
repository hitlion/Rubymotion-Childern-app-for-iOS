class OverlayScreenshotCell < UICollectionViewCell

  attr_accessor :screenshot, :delegate

  def initWithFrame(frame)
    super(frame)
    @delegate = self
    self
  end

  ##
  # Build the cell with the data from the given element
  # @param element [UIImage] The Story for filling the data of this cell
  def make_cell(element)
    @screenshot = element

    return if(@screenshot.nil?)

    view = UIImageView.alloc.initWithFrame(CGRectMake(0,0,self.frame.size.width, self.frame.size.height))
    view.backgroundColor = UIColor.whiteColor
    view.image = @screenshot

    self.subviews.each do |s|
      s.removeFromSuperview
    end

    self.addSubview(view)
  end
end