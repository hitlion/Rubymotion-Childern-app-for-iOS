class StoryLoggerView < UIView

  def initWithFrame( frame )
    super.tap do
      @filter = :java_script
      @scroll = true
      @hidden = true

      rmq(self).stylesheet = StoryLoggerStylesheet
      rmq(self).apply_style(:root)

      append(UIButton, :switch_mode_button).on(:tap) do
        if @filter == :java_script
          rmq(@all_messages).show
          rmq(@script_messages).hide
          @filter = :all

          rmq(:switch_mode_button).data('[Console]')
        else
          rmq(@all_messages).hide
          rmq(@script_messages).show
          @filter = :java_script

          rmq(:switch_mode_button).data('[JavaScript]')
        end
      end

      append(UIButton, :dismiss_button).on(:tap) do
        hide
      end

      append(UIButton, :scroll_lock_button).on(:tap) do
        @scroll = !@scroll
        rmq(:scroll_lock_button).data("[scroll: #{@scroll}]")
      end

      @all_messages = append(UITextView, :log_messages_view).get
      @script_messages = append(UITextView, :log_messages_view).get

      rmq(@all_messages).hide

      NSNotificationCenter.defaultCenter.addObserver(self,
                                                    selector: 'update_contents:',
                                                    name: 'LogMessageAvailable',
                                                    object: nil)

      NSNotificationCenter.defaultCenter.addObserver(self,
                                                    selector: 'update_contents:',
                                                    name: 'ScriptMessageAvailable',
                                                    object: nil)


      rmq(self).hide
      rmq(self).animations.slide_out(to_direction: :top)
    end
  end

  def dealloc
    NSNotificationCenter.removeObserver(self)
  end

  def update_contents( notification )
    if notification.name == 'LogMessageAvailable'
      add_log_message( @all_messages, notification.object )
    elsif notification.name == 'ScriptMessageAvailable'
      add_log_message( @script_messages, notification.object )
    end
  end

  # Show the logger view if it's hidden.
  def show
    return unless @hidden

    @hidden = false

    self.center = self.superview.center # required for slide_in to work
    rmq(self).show
    rmq(self).animations.slide_in(from_direction: :top)
  end

  # Hide the logger view if it's visible
  def hide
    return if @hidden

    @hidden = true
    rmq(self).animations.slide_out(to_direction: :top)
  end

  # Toggle the logger views visibility
  def toggle
    if @hidden
      show
    else
      hide
    end
  end

  private

  def add_log_message( log_view, message )
    Dispatch::Queue.main.async do
      text = log_view.attributedText.mutableCopy

      while text.length + message.length >= 2048
            line_range = text.mutableString.lineRangeForRange(NSMakeRange(0, 1))
            text.deleteCharactersInRange(line_range)
      end
      text.appendAttributedString(message)
      log_view.attributedText = text

      if @scroll && text.length > 0
        log_view.scrollRangeToVisible(NSMakeRange(text.length - 1, text.length))
      end
    end
  end
end

