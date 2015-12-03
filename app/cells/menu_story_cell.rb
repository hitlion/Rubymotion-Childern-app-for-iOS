class MenuStoryCell < UICollectionViewCell

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
    @element = element

    return if(@element.nil?)

    view = UIView.alloc.initWithFrame(self.bounds)
    view.backgroundColor = UIColor.redColor

    image = UIImageView.alloc.initWithFrame(CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
    image.image = UIImage.imageWithData(element.asset_data(element.document.thumbnail))

    layer = UIImageView.alloc.initWithFrame(CGRectMake(0, 0, 0.75 * view.frame.size.width, 0.33 * view.frame.size.height ))
    layer.image = UIImage.imageNamed("cell_layer")

    label = UILabel.alloc.initWithFrame(CGRectMake(0, 0, layer.frame.size.width, 0.5 * layer.frame.size.height))
    label.text = element.document.branch_name
    label.textColor = UIColor.blackColor
    label.font = UIFont.fontWithName("Enriqueta-Bold", size:30)
    label.textAlignment = UITextAlignmentCenter

    left_button = UIButton.alloc.initWithFrame(CGRectMake(0.15 * layer.frame.size.width,0.6 * layer.frame.size.height,
                                                          0.3 * layer.frame.size.width, 0.3 * layer.frame.size.height))
    left_button.setBackgroundImage(UIImage.imageNamed("button_grey.png"), forState:UIControlStateNormal)
    left_button.setTitle("Mehr", forState: UIControlStateNormal)
    left_button.addTarget(self, action: "left_button_pressed:", forControlEvents: UIControlEventTouchUpInside)
    left_button.tag = element.object_id
    left_button.font = UIFont.fontWithName("Enriqueta-Regular", size:15)

    right_button = UIButton.alloc.initWithFrame(CGRectMake(0.55 * layer.frame.size.width,0.6 * layer.frame.size.height,
                                                           0.3 * layer.frame.size.width, 0.3 * layer.frame.size.height))
    right_button.setBackgroundImage(UIImage.imageNamed("button_orange.png"), forState:UIControlStateNormal)
    right_button.setTitle("Öffnen", forState: UIControlStateNormal)
    right_button.addTarget(self, action: "right_button_pressed:", forControlEvents: UIControlEventTouchUpInside)
    right_button.tag = element.object_id
    right_button.font = UIFont.fontWithName("Enriqueta-Regular", size:15)

    @selected_story_marker = UIImageView.alloc.initWithFrame(CGRectMake(CGRectGetMidX(view.bounds)- 0.05 *  view.frame.size.width,
                                                                     view.frame.size.height - 0.05 * view.frame.size.width,
                                                                     0.1 * view.frame.size.width, 0.05 * view.frame.size.width))
    @selected_story_marker.image = UIImage.imageNamed("Marker.png")
    hide_marker

    view.addSubview(image)
    view.addSubview(layer)
    view.addSubview(label)
    view.addSubview(left_button)
    view.addSubview(right_button)
    view.addSubview(@selected_story_marker)

    self.subviews.each do |s|
      s.removeFromSuperview
    end

    self.addSubview(view)
  end

  ##
  # Hide the marker, that shows this story is selected
  def hide_marker
    @selected_story_marker.hidden = true
  end

  ##
  # Show the marker, that shows this story is selected
  def show_marker
    @selected_story_marker.hidden = false
  end

  ##
  # Called if the user pressed the right button of the cell
  # than call the delegate method with the params self (this collection view cell) and the button element
  # @param source [UIButton] the pressed cell's button
  def right_button_pressed (source)
    @delegate.menuStoryCell(self, rightButtonPressed: source) unless @delegate == self
    #@delegate.menuStoryCell(self, rightButtonPressed: source) if @delegate.respond_to? 'menuStoryCell:rightButtonPressed:' #optinal
  end

  ##
  # Called if the user pressed the left button of the cell
  # than call the delegate method with the params self (this collection view cell) and the button element
  # @param source [UIButton] the pressed cell's button
  def left_button_pressed (source)
    if(@delegate != self)
     @delegate.send('menuStoryCell:leftButtonPressed:', self, source)
    end
  end
end