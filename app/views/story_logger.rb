class StoryLoggerView < UIView

  attr_accessor :touch_target

  def initWithFrame( frame )
    super.tap do
      @scroll        = true
      @hidden        = true

      rmq(self).stylesheet = StoryLoggerStylesheet
      rmq(self).apply_style(:root)

      append(UISegmentedControl, :switch_mode_button).on(:change) do |sender, _|
        if sender.selectedSegmentIndex == 0
          rmq(@all_messages).hide
          rmq(@script_messages).show
        else
          rmq(@all_messages).show
          rmq(@script_messages).hide
        end
      end

      append(UIButton, :dismiss_button).on(:tap) { hide }

      append(UISwitch, :scroll_lock_switch).on(:change) do |sender, _|
        @scroll = sender.on?
      end

      append(UILabel, :scroll_lock_label)

      append(UISwitch, :tranparent_touch_switch_switch).on(:change) do |sender, _|
        set_exclusive_touch(!sender.on?)
      end

      append(UILabel, :tranparent_touch_switch_label)
      append(UIButton, :quit_story_button).on(:touch_up) do |_, _|
        if(rmq.screen)
          rmq.screen.close
        end
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
      set_exclusive_touch(false)
    end
  end

  # @private
  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver(self)
    super
  end

  # @private
  # callback for log message notifications
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

    set_exclusive_touch(!rmq(:tranparent_touch_switch_switch).get.on?)
  end

  # Hide the logger view if it's visible
  def hide
    return if @hidden

    @hidden = true
    rmq(self).animations.slide_out(to_direction: :top)
    set_exclusive_touch(false)
  end

  # Toggle the logger views visibility
  def toggle
    if @hidden
      show
    else
      hide
    end
  end

  def clear!
    @all_messages.attributedText = NSAttributedString.alloc.initWithString('')
    @script_messages.attributedText = NSAttributedString.alloc.initWithString('')
  end

  private

  def add_log_message( log_view, message )
    Dispatch::Queue.main.async do
      text = log_view.attributedText.mutableCopy

      while text.length && (text.length + message.length >= 2048)
        break if text.length == 0

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

  def set_exclusive_touch(active)
    if active
      exclusiveTouch = true
      if superview.respond_to? :gestureRecognizers
        superview.gestureRecognizers.each { |r| r.enabled = false }
      end
    else
      exclusiveTouch = false
      if superview.respond_to? :gestureRecognizers
        superview.gestureRecognizers.each { |r| r.enabled = true }
      end
    end
  end
end

