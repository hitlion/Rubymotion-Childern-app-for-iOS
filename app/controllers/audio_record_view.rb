class AudioRecordView < UIView

  attr_reader :recorder, :player, :settings, :session
  attr_accessor :delegate


  def initWithFrame( frame )
    super.tap do

      rmq(self).stylesheet = AudioRecordViewStylesheet
      rmq(self).apply_style(:root)

      append(UIView, :background_layer)

      append(UIButton, :cancel_button).on(:tap) do
        cancel_record
      end

      @save_button = append!(UIButton, :ok_button)
      @save_button.hidden = true
      @save_button.on(:tap) do
        save_button_pressed
      end

      @repeat_button = append!(UIButton, :repeat_button)
      @repeat_button.hidden = true
      @repeat_button.on(:tap) do
        repeat_button_pressed
      end

      @record_button = append!(UIButton, :record_button)
      @record_button.on(:tap) do
        record_button_pressed
      end

      @stop_button = append!(UIButton, :stop_button)
      @stop_button.hidden = true
      @stop_button.on(:tap) do
        stop_button_pressed
      end

      @play_button = append!(UIButton, :play_button)
      @play_button.hidden = true
      @play_button.on(:tap) do
        play_button_pressed
      end

      @session = AVAudioSession.sharedInstance
      @session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)

    end
  end

  def cancel_record
    NSFileManager.defaultManager.removeItemAtPath(@output_file_URL, error: nil)
    hide
  end

  def hide
    @output_file_URL = nil

    if @recorder
      @recorder.stop if @recorder.recording?
      @recorder = nil
    end

    if @player
      @player.stop if @player.playing?
      @player = nil
    end

    self.hidden = true
    # disable touch capturing
    off
  end

  def show(path, delegate)

    @delegate = delegate
    @output_file_URL = NSURL.fileURLWithPath(path)

    # Initiate and prepare the recorder

    error = Pointer.new(:object)
    @recorder = AVAudioRecorder.alloc.initWithURL(@output_file_URL, settings: self.audio_recording_settings, error: error)

    @recorder.delegate = self
    @recorder.meteringEnabled= true
    @recorder.prepareToRecord

    @repeat_button.hidden = true
    @save_button.hidden = true
    @play_button.hidden = true
    @stop_button.hidden = true
    @record_button.hidden = false
    self.hidden = false

    # catch taps on this view to prevent accidential hiding
    on(:tap) { |_, _| }
  end

  def audio_recording_settings
    result = nil
    settings = NSMutableDictionary.alloc.init

    settings.setValue(NSNumber.numberWithInteger(KAudioFormatAppleLossless), forKey:AVFormatIDKey)
    settings.setValue(NSNumber.numberWithFloat(44100.0), forKey:AVSampleRateKey)
    settings.setValue(NSNumber.numberWithInteger(1), forKey:AVNumberOfChannelsKey)
    settings.setValue(NSNumber.numberWithInteger(AVAudioQualityLow), forKey:AVEncoderAudioQualityKey)

    result = NSDictionary.dictionaryWithDictionary(settings)
    result
  end

  def audioRecorderDidFinishRecording(recorder, successfully:flag)
    @play_button.hidden = false
    @stop_button.hidden = true
    @repeat_button.hidden = false
    @save_button.hidden = false
  end

  def audioPlayerDidFinishPlaying(player, successfully:flag)
    @play_button.hidden = false
    @stop_button.hidden = true
  end

  private

  def record_button_pressed
    @record_button.hidden = true
    @stop_button.hidden = false
    unless @recorder.recording?
      @session.setActive(true, error:nil)
      @recorder.record
    end
  end

  def play_button_pressed
    @play_button.hidden = true
    @stop_button.hidden = false

    unless @recorder.recording?
      @player = AVAudioPlayer.alloc.initWithContentsOfURL(@recorder.url, error: nil)
      @player.delegate = self
      @player.play
    end

  end

  def stop_button_pressed
    if @recorder.recording?
      @recorder.stop
      @session.setActive(false, error:nil)
    elsif @player.playing?
      @player.stop
      @play_button.hidden = false
      @stop_button.hidden = true
    end
  end

  def save_button_pressed
    @delegate.audio_available(@output_file_URL) if @delegate.respond_to? :'audio_available:'
    hide
  end

  def repeat_button_pressed
    @repeat_button.hidden = true
    @save_button.hidden = true
    @play_button.hidden = true
    @stop_button.hidden = true
    @record_button.hidden = false
  end


end