class MenuStoryCell < UICollectionViewCell

  attr_accessor :delegate, :element

  def initWithFrame(frame)
    super.tap do
      @delegate = WeakRef.new(self)

      self.backgroundColor = rmq.color.babbo_orange

      @background_image = UIImageView.alloc.initWithFrame(self.bounds)
      @background_image.backgroundColor = rmq.color.blue
      @background_image.off
      @background_image.on(:tap) do
        right_button_pressed(@right_button)
      end

      append(@background_image) unless @background_image.nil?

      layer = UIImageView.alloc.initWithFrame(CGRectMake(0, 0, 0.75 * self.frame.size.width, 0.33 * self.frame.size.height ))
      layer.image = rmq.image.resource("cells/cell_layer.png")
      append(layer) unless layer.nil?

      @label = UILabel.alloc.initWithFrame(CGRectMake(0, 0, layer.frame.size.width, 0.5 * layer.frame.size.height))
      @label.text = 'no text found'
      @label.textColor = rmq.color.black
      device.ipad? ? @label.font = rmq.font.pad_large : @label.font = rmq.font.phone_large_bold

      @label.textAlignment = UITextAlignmentCenter
      append(@label) unless @label.nil?

      @left_button = UIButton.alloc.initWithFrame(CGRectMake(0.025 * layer.frame.size.width,0.6 * layer.frame.size.height,
                                                            0.425 * layer.frame.size.width, 0.35 * layer.frame.size.height))
      @left_button.setBackgroundImage(rmq.image.resource("button_grey.png"), forState:UIControlStateNormal)
      @left_button.setTitle("Mehr", forState: UIControlStateNormal)
      device.ipad? ? @left_button.font = rmq.font.pad_medium : @left_button.font = rmq.font.phone_medium

      @left_button.off
      @left_button.on(:tap) do
        left_button_pressed(@left_button)
      end
      append(@left_button) unless @left_button.nil?

      @right_button = UIButton.alloc.initWithFrame(CGRectMake(0.50 * layer.frame.size.width,0.6 * layer.frame.size.height,
                                                             0.425 * layer.frame.size.width, 0.35 * layer.frame.size.height))
      @right_button.setBackgroundImage(rmq.image.resource("button_orange.png"), forState:UIControlStateNormal)
      @right_button.setTitle("Öffnen", forState: UIControlStateNormal)

      device.ipad? ? @right_button.font = rmq.font.pad_medium : @right_button.font = rmq.font.phone_medium
      @right_button.off
      @right_button.on(:tap) do
        right_button_pressed(@right_button)
      end
      append(@right_button) unless @right_button.nil?



      @selected_story_marker = UIImageView.alloc.initWithFrame(CGRectMake(CGRectGetMidX(self.bounds)- 0.05 *  self.frame.size.width,
                                                                          self.frame.size.height - 0.05 * self.frame.size.width,
                                                                          0.1 * self.frame.size.width, 0.05 * self.frame.size.width))
      @selected_story_marker.image = UIImage.imageNamed("Marker.png")
      hide_marker
      append(@selected_story_marker) unless @selected_story_marker.nil?

    end
  end

  ##
  # Build the cell with the data from the given element
  # @param element [Story] The Story for filling the data of this cell
  def make_cell(element)
    @element = element

    return if(@element.nil?)
    @background_image.image = UIImage.imageWithData(element.asset_data(element.document.thumbnail))
    @label.text = element.document.branch_name
    @right_button.tag = element.object_id
    @left_button.tag = element.object_id
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
    @delegate.menuStoryCell(self, rightButtonPressed: source) if @delegate.respond_to? 'menuStoryCell:rightButtonPressed:'
  end

  ##
  # Called if the user pressed the left button of the cell
  # than call the delegate method with the params self (this collection view cell) and the button element
  # @param source [UIButton] the pressed cell's button
  def left_button_pressed (source)
    @delegate.menuStoryCell(self, leftButtonPressed: source) if @delegate.respond_to? 'menuStoryCell:leftButtonPressed:'
  end

end