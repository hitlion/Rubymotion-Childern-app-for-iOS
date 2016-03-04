# This module encapsulates the logic required to record audio samples.
#
# If included the including class should be a UIViewController.
# This module uses the following callbacks if they are implemented:
#
# media_chooser_popup_anchor
#  - is called if the device is an iPad and a PopOver should be shown
#  - should return the anchor point (a UIView, UIBarButten etc).
#
# audio_available( media_url )
#  - called once the user takes records an audio sample
#  - 'media_url' is the location of the recorded sample
#
# audio_canceled
#  - called when the user dismisses the picker without recording
#
module AudioRecorder
  # Present an audio recorder for recording at a given path
  #
  # @param [String] path The path to save the resulting audio to
  def present_audio_recorder( path )
    NSLog("Audio record startet")
    @audio_record_target = path

    recorder = IQAudioRecorderController.alloc.init
    recorder.delegate = self

    if device.iphone?
      self.presentViewController( recorder, animated: true , completion: nil )
    elsif device.ipad?
      pop_over = UIPopoverController.alloc.initWithContentViewController( recorder )
      if self.respond_to? :media_chooser_popup_anchor
        anchor = self.media_chooser_popup_anchor
        center_point = self.view.convertPoint(anchor.center, toView: self.view)

        pop_over.presentPopoverFromRect([[center_point.x, center_point.y], [10, 10]],
                                        inView: self.view,
                                        permittedArrowDirections: UIPopoverArrowDirectionAny,
                                        animated: true)
      else
        pop_over.presentPopoverFromRect([[-5.0 + self.view.size.width / 2.0,
                                          -5.0 + self.view.size.height / 2.0], [10, 10]],
                                        inView: self.view,
                                        permittedArrowDirections: UIPopoverArrowDirectionAny,
                                        animated: true)
      end
      @audio_popup_helper = pop_over
    end
  end

  # @private
  def audioRecorderController( recorder, didFinishWithAudioAtPath: path )

    File.rename(path.fileSystemRepresentation, @audio_record_target)

    if self.respond_to? :'audio_available:'
      self.audio_available(@audio_record_target)
    end

    if ! @audio_popup_helper.nil?
      @audio_popup_helper.dismissPopoverAnimated(true)
      @audio_popup_helper = nil
    else
      recorder.dismissModalViewControllerAnimated(true, completion: nil)
    end
  end

  # @private
  def audioRecorderControllerDidCancel( recorder )
    if self.respond_to? :'audio_canceled'
      self.audio_canceled
    end

    if ! @audio_popup_helper.nil?
      @audio_popup_helper.dismissPopoverAnimated(true)
      @audio_popup_helper = nil
    else
      recorder.dismissModalViewControllerAnimated(true, completion: nil)
    end
  end
end

