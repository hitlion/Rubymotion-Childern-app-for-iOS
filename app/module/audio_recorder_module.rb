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
module AudioRecorderModule

  attr_reader :delegate

  # Present an audio recorder for recording at a given path
  #
  # @param [String] path The path to save the resulting audio to
  def present_audio_recorder( path, delegate)
    @delegate = delegate
    NSLog("Audio record startet")
    @audio_record_target = path


  end

  # @private
  def audioRecorderController( recorder, didFinishWithAudioAtPath: path )

    File.rename(path.fileSystemRepresentation, @audio_record_target)

    if @delegate.respond_to? :'audio_available:'
      @delegate.audio_available(@audio_record_target)
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
    if @delegate.respond_to? :'audio_canceled'
      @delegate.audio_canceled
    end

    if ! @audio_popup_helper.nil?
      @audio_popup_helper.dismissPopoverAnimated(true)
      @audio_popup_helper = nil
    else
      recorder.dismissModalViewControllerAnimated(true, completion: nil)
    end
  end
end

