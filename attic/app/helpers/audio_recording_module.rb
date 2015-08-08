module Babbo
  module AudioRecorder
    def present_audio_recorder( path )
      @audio_record_target = path

      recorder = IQAudioRecorderController.alloc.init
      recorder.delegate = self

      if UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone
        self.presentViewController( recorder, animated: true , completion: nil )
      elsif UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
        pop_over = UIPopoverController.alloc.initWithContentViewController( recorder )
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
        @audio_popup_helper = pop_over
      end
    end

    def audioRecorderController( recorder, didFinishWithAudioAtPath: path )
      File.rename( path, @audio_record_target )

      if self.respond_to? :'audio_available:'
        self.audio_available( @audio_record_target )
      end

      if ! @audio_popup_helper.nil?
        @audio_popup_helper.dismissPopoverAnimated( true )
        @audio_popup_helper = nil
      else
        recorder.dismissModalViewControllerAnimated( true, completion: nil )
      end
    end

    def audioRecorderControllerDidCancel( recorder )
      if self.respond_to? :'audio_canceled'
        self.audio_canceled
      end

      if ! @audio_popup_helper.nil?
        @audio_popup_helper.dismissPopoverAnimated( true )
        @audio_popup_helper = nil
      else
        recorder.dismissModalViewControllerAnimated( true, completion: nil )
      end
    end
  end
end

