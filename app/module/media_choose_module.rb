# This module encapsulates the logic required to choose a photo
# or video from the devices camera, camera roll or saved albums.
#
# If included the including class should be a UIViewController.
# This module uses the following callbacks if they are implemented:
#
# media_chooser_popup_anchor
#  - is called if the device is an iPad and a PopOver should be shown
#  - should return the anchor point (a UIView, UIBarButten etc).
#
# photo_available( image )
#  - called once the user takes a picture or chooses a photo
#  - 'image' contains the final UIImage
#
# photo_canceled
#  - called when the user dismisses the picker without choosing
#    a photo or a new picture
#
# video_available( media_url )
#  - called once the user takes a picture or chooses a photo
#  - 'media_url' is the location of the recorded video
#
# video_canceled
#  - called when the user dismisses the picker without choosing
#    a video
#

module MediaChooseModule

  attr_reader :delegate

  include OrientationModule

  # Present a photo chooser
  def present_photo_chooser(delegate)
    @delegate = delegate
    if UIImagePickerController.isSourceTypeAvailable( UIImagePickerControllerSourceTypeCamera )
      ask_for_photo_source
    else
      run_photo_chooser(UIImagePickerControllerSourceTypePhotoLibrary)
    end
  end

  # Present a video chooser
  def present_video_chooser(delegate)
    @delegate = delegate
    if UIImagePickerController.isSourceTypeAvailable( UIImagePickerControllerSourceTypeCamera )
      ask_for_video_source
    else
      run_video_chooser(UIImagePickerControllerSourceTypePhotoLibrary)
    end
  end


  # Ask the user for the desired photo source.
  # Possible responses are: 'camera' or 'album'
  def ask_for_photo_source
    rmq.app.alert(title: 'Quelle', message: "Quelle auswählen", actions: ['Kamera', 'Album', :cancel]) do |button_tag|
      case button_tag
        when 'Kamera'
        run_photo_chooser(UIImagePickerControllerSourceTypeCamera)
        @new = true
      when 'Album'
        run_photo_chooser(UIImagePickerControllerSourceTypePhotoLibrary)
        @new = false
      when :cancel
      end
    end
  end

  # Ask the user for the desired video source.
  # Possible responses are: 'camera' or 'album'
  def ask_for_video_source
    rmq.app.alert(title: 'Quelle', message: "Quelle auswählen", actions: ['Kamera', 'Album', :cancel]) do |button_tag|
      case button_tag
      when 'Kamera'
        run_video_chooser(UIImagePickerControllerSourceTypeCamera)
        @new = true
      when 'Album'
        run_video_chooser(UIImagePickerControllerSourceTypePhotoLibrary)
        @new = false
      when :cancel
      end
    end
  end

  private

  # Run a photo chooser for the given source
  #
  # @param [UIImagePickerControllerSourceType] source The source to pick an
  #  image from. Supported values: 
  #  UIImagePickerControllerSourceTypePhotoLibrary
  #  UIImagePickerControllerSourceTypeCamera
  #  UIImagePickerControllerSourceTypeSavedPhotosAlbum
  def run_photo_chooser( source )
    image_picker = UIImagePickerController.alloc.init
    image_picker.mediaTypes = [KUTTypeImage]
    image_picker.allowsEditing = true
    image_picker.delegate = self
    image_picker.sourceType = source

    if device.iphone?
      self.presentModalViewController(image_picker, animated: true) #old solution by rene
      #self.addChildViewController(image_picker)
      #image_picker.didMoveToParentViewController(self)
      #self.view.addSubview(image_picker.view)
      #@image_picker_for_iphone = image_picker
    elsif device.ipad?
      pop_over = UIPopoverController.alloc.initWithContentViewController(image_picker)
      if self.respond_to? :media_chooser_popup_anchor
        anchor = self.media_chooser_popup_anchor
        center_point = self.view.convertPoint(anchor.center, fromView: anchor)

        pop_over.presentPopoverFromRect([[center_point.x, center_point.y], [10, 10] ],
                                         inView: self.view,
                                         permittedArrowDirections: UIPopoverArrowDirectionAny,
                                         animated: true)
      else
        pop_over.presentPopoverFromRect([[-5.0 + self.view.size.width / 2.0,
                                           -5.0 + self.view.size.height / 2.0], [10, 10] ],
                                         inView: self.view,
                                         permittedArrowDirections: UIPopoverArrowDirectionAny,
                                         animated: true)
      end
      @photo_popup_helper = pop_over
    end
  end

  # Run a photo chooser for the given source
  #
  # @param [UIImagePickerControllerSourceType] source The source to pick an
  #  image from. Supported values: 
  #  UIImagePickerControllerSourceTypePhotoLibrary
  #  UIImagePickerControllerSourceTypeCamera
  def run_video_chooser( source )

    all_media_types = UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceTypeCamera)
    video_media_types = all_media_types.filteredArrayUsingPredicate(NSPredicate.predicateWithFormat('(SELF contains %@)', 'movie'))

    video_picker = UIImagePickerController.alloc.init
    video_picker.mediaTypes = video_media_types
    video_picker.videoQuality = UIImagePickerControllerQualityTypeMedium
    video_picker.allowsEditing = true
    video_picker.delegate = self
    video_picker.sourceType = source

    if device.iphone?
      self.presentModalViewController(video_picker, animated: true) # old solution by rene
      # self.addChildViewController(video_picker)
      # video_picker.didMoveToParentViewController(self)
      # self.view.addSubview(video_picker.view)
      # @video_picker_for_iphone = video_picker
    elsif device.ipad?
      pop_over = UIPopoverController.alloc.initWithContentViewController(video_picker)
      if self.respond_to? :media_chooser_popup_anchor
        anchor = self.media_chooser_popup_anchor
        center_point = self.view.convertPoint(anchor.center, fromView: anchor)
        pop_over.presentPopoverFromRect([[center_point.x, center_point.y], [10, 10] ],
                                         inView: self.view,
                                         permittedArrowDirections: UIPopoverArrowDirectionDown,
                                         animated: true)

      else
        pop_over.presentPopoverFromRect([[-5.0 + self.view.size.width / 2.0,
                                           -5.0 + self.view.size.height / 2.0], [10, 10] ],
                                         inView: self.view,
                                         permittedArrowDirections: UIPopoverArrowDirectionDown,
                                         animated: true)
      end
      @photo_popup_helper = pop_over
    end
  end

  public

  ## Mark: UIImagePickerControllerDelegate

  # @private
  def imagePickerController( image_picker, didFinishPickingMediaWithInfo: meta )
    lp 'picker done'
    if image_picker.mediaTypes == [KUTTypeImage]
      lp 'picker was for images'
      image = meta[UIImagePickerControllerEditedImage]
      if @delegate.respond_to? :'photo_available:'
        lp 'callback available'
        @delegate.photo_available(image, @new)
      end
    else
      # video callback
      if @delegate.respond_to? :'video_available:'
        video_url = meta[UIImagePickerControllerMediaURL]
        @delegate.video_available(video_url, @new)
      end
    end

    if ! @photo_popup_helper.nil?
      @photo_popup_helper.dismissPopoverAnimated(true)
    else
      image_picker.dismissModalViewControllerAnimated(true, completion: nil)
    end
  end

  # @private
  def imagePickerControllerDidCancel(image_picker)
    if image_picker.mediaTypes == [KUTTypeImage]
      if @delegate.respond_to? :'photo_canceled'
        @delegate.photo_canceled
      end
    else
      if @delegate.respond_to? :'video_canceled'
        @delegate.video_canceled
      end
    end
    if ! @photo_popup_helper.nil?
      @photo_popup_helper.dismissPopoverAnimated(true)
    else
      image_picker.dismissModalViewControllerAnimated(true, completion: nil)
    end
  end
end

