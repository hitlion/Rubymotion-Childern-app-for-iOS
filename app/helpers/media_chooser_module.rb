module Babbo
  module MediaChooser
    def present_photo_chooser
      if UIImagePickerController.isSourceTypeAvailable( UIImagePickerControllerSourceTypeCamera )
        ask_for_photo_source
      else
         run_photo_chooser( UIImagePickerControllerSourceTypePhotoLibrary )
      end
    end

    def present_video_chooser
      if UIImagePickerController.isSourceTypeAvailable( UIImagePickerControllerSourceTypeCamera )
        ask_for_photo_source
      else
         run_photo_chooser( UIImagePickerControllerSourceTypePhotoLibrary )
      end
    end

    def run_photo_chooser( source )
      image_picker = UIImagePickerController.alloc.init
      image_picker.mediaTypes = [KUTTypeImage]
      image_picker.allowsEditing = true
      image_picker.delegate = self
      image_picker.sourceType = source

      if UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone
        self.presentModalViewController( image_picker, animated: true )
      elsif UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
        pop_over = UIPopoverController.alloc.initWithContentViewController( image_picker )
        if self.respond_to? :photo_chooser_popup_anchor
          anchor = self.photo_chooser_popup_anchor
          pop_over.presentPopoverFromBarButtonItem( anchor,
                                           permittedArrowDirections: UIPopoverArrowDirectionDown,
                                           animated: true )
        else
          pop_over.presentPopoverFromRect( [[-5.0 + self.view.size.width / 2.0,
                                             -5.0 + self.view.size.height / 2.0], [10, 10] ],
                                           inView: self.view,
                                           permittedArrowDirections: UIPopoverArrowDirectionDown,
                                           animated: true )
        end
        @photo_popup_helper = pop_over
      end
    end

    def ask_for_photo_source
      @photo_source_action_sheet = UIActionSheet.alloc.initWithTitle( "Quelle",
                                                                    delegate: self,
                                                                    cancelButtonTitle: "Abbrechen",
                                                                    destructiveButtonTitle: nil,
                                                                    otherButtonTitles: nil)
      @photo_source_action_sheet.addButtonWithTitle( 'Kamera' )
      @photo_source_action_sheet.addButtonWithTitle( 'Album'  )

      if UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone
        @photo_source_action_sheet.showInView( self.view )
      elsif UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
        if self.respond_to? :photo_chooser_popup_anchor
          anchor = self.photo_chooser_popup_anchor
          @photo_source_action_sheet.showFromBarButtonItem( anchor, animated: true )
        else
          @photo_source_action_sheet.showInView( self.view )
        end
      end
    end

    def actionSheet( sheet, didDismissWithButtonIndex: index )
      case sheet.buttonTitleAtIndex( index )
        when 'Album'
          mp_l "choose existing"
          run_photo_chooser( UIImagePickerControllerSourceTypePhotoLibrary )
        when 'Kamera'
          mp_l "choose camera"
          run_photo_chooser( UIImagePickerControllerSourceTypeCamera )
      end
    end

    # UIImagePickerControllerDelegate
    def imagePickerController( image_picker, didFinishPickingMediaWithInfo: meta )
      image = meta[UIImagePickerControllerEditedImage]
      if self.respond_to? :'photo_available:'
        self.photo_available( image )
      end
      if ! @photo_popup_helper.nil?
        @photo_popup_helper.dismissPopoverAnimated( true )
      else
        image_picker.dismissModalViewControllerAnimated( true, completion: nil )
      end
    end

    def imagePickerControllerDidCancel( image_picker )
      if self.respond_to? :'photo_canceled'
        self.photo_canceled
      end
      if ! @photo_popup_helper.nil?
        @photo_popup_helper.dismissPopoverAnimated( true )
      else
        image_picker.dismissModalViewControllerAnimated( true, completion: nil )
      end
    end
  end
end

