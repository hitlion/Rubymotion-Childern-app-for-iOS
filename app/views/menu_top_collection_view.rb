class MenuTopCollectionView < UICollectionView

  CellIdentifier = 'Cell'

  def initWithFrame(frame, cellElements: elements)

    layout = UICollectionViewFlowLayout.alloc.init
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal
    cell_height = self.frame.size.height
    cell_width  = (4.0 * cell_height) / 3.0
    cell_size = CGSizeMake(cell_width, cell_height)
    layout.itemSize = cell_size

    super(frame, collectionViewLayout:layout)

    make_story_collection_view_cells(cellSize, cellElements: elements)

    self.contentInset = UIEdgeInsetsMake(0, 0 * self.frame.size.width, 0, 0 * self.frame.size.width)

    self.registerClass(UICollectionViewCell, forCellWithReuseIdentifier: CellIdentifier
    self.backgroundColor = UIColor.clearColor

    self
  end

  def make_story_collection_view_cells(cellSize, cellElements: elements)
    @story_collection_view_cells = []

    elements.each_with_index do |elements, index|

      view = UIView.alloc.initWithFrame(CGRectMake(0,0,itemSize.width, itemSize.height))
      view.backgroundColor = UIColor.redColor

      image = UIImageView.alloc.initWithFrame(CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
      image.image = UIImage.imageWithData(elements[0].asset_data(elements[0].document.thumbnail))

      layer = UIImageView.alloc.initWithFrame(CGRectMake(0, 0, 0.75 * view.frame.size.width, 0.33 * view.frame.size.height ))
      layer.image = UIImage.imageNamed("cell_layer.png")

      label = UILabel.alloc.initWithFrame(CGRectMake(0, 0, layer.frame.size.width, 0.5 * layer.frame.size.height))
      label.text = elements[0].document.set_name
      label.textColor = UIColor.blackColor
      label.font = UIFont.fontWithName("Enriqueta-Bold", size:30)
      label.textAlignment = UITextAlignmentCenter

      left_button = UIButton.alloc.initWithFrame(CGRectMake(0.15 * layer.frame.size.width,0.6 * layer.frame.size.height,
                                                            0.3 * layer.frame.size.width, 0.3 * layer.frame.size.height))
      left_button.setBackgroundImage(UIImage.imageNamed("button_grey.png"), forState:UIControlStateNormal)
      left_button.setTitle("Mehr", forState: UIControlStateNormal)
      left_button.addTarget(self.delegate, action: "top_collection_view_button_1:", forControlEvents: UIControlEventTouchUpInside)
      right_button = UIButton.alloc.initWithFrame(CGRectMake(0.55 * layer.frame.size.width,0.6 * layer.frame.size.height,
                                                             0.3 * layer.frame.size.width, 0.3 * layer.frame.size.height))
      right_button.setBackgroundImage(UIImage.imageNamed("button_orange.png"), forState:UIControlStateNormal)
      right_button.setTitle("Spielen", forState: UIControlStateNormal)
      right_button.addTarget(self.delegate, action: "top_collection_view_button_2:", forControlEvents: UIControlEventTouchUpInside)

      selectedStoryMarker = UIImageView.alloc.initWithFrame(CGRectMake(CGRectGetMidX(view.bounds)- 0.05 *  view.frame.size.width,
                                                                       view.frame.size.height - 0.05 * view.frame.size.width,
                                                                       0.1 * view.frame.size.width, 0.05 * view.frame.size.width))

      selectedStoryMarker.image = UIImage.imageNamed("Marker.png")

      view.addSubview(image)
      view.addSubview(layer)
      view.addSubview(label)
      view.addSubview(left_button)
      view.addSubview(right_button)
      view.addSubview(selectedStoryMarker)

      @story_collection_view_cells[index] = view
    end
  end
end