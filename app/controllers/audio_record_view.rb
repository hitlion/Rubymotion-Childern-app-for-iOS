class AudioRecordView < UIView

  attr_reader :recorder, :player, :state
  attr_accessor :delegate


  def initWithFrame( frame )
    super.tap do

      rmq(self).stylesheet = AudioRecordViewStylesheet
      rmq(self).apply_style(:root)

      append(UIView, :background_layer)

      append(UIButton, :cancel_button).on(:tap) do
        hide
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
    end

  end

  def hide
    return if self.hidden = true
    self.hidden = true
    # disable touch capturing
    off
  end

  def show
    return unless self.hidden = false
    self.hidden = false

    lp "Show: #{@state}", force_color: :purple

    # catch taps on this view to prevent accidential hiding
    on(:tap) { |_, _| }
  end

  private

  def record_button_pressed
    @record_button.hidden = true
    @stop_button.hidden = false
  end

  def play_button_pressed
    @play_button.hidden = true
    @stop_button.hidden = false
  end

  def stop_button_pressed
    @play_button.hidden = false
    @stop_button.hidden = true
    @repeat_button.hidden = false
    @save_button.hidden = false
  end

  def save_button_pressed

  end

  def repeat_button_pressed
    @repeat_button.hidden = true
    @save_button.hidden = true
    @play_button.hidden = true
    @stop_button.hidden = true
    @record_button.hidden = false
  end


end