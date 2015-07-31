class SystemLogView < UIView
  class << self
    attr_accessor :messages, :jscript

    SystemLogView.messages = NSMutableAttributedString.alloc.initWithString( '' )
    SystemLogView.jscript  = NSMutableAttributedString.alloc.initWithString( '' )

    def log_message( message, color=nil )
      clear if SystemLogView.messages.length >= 102400

      SystemLogView.messages.appendAttributedString( SystemLogView.create_log_message( message, color ) )
      NSNotificationCenter.defaultCenter.postNotificationName( 'StoryLogChanged', object: nil )
    end

    def log_jscript( message, color=nil )
      clear if SystemLogView.jscript.length >= 102400

      msg = SystemLogView.create_log_message( message, color )

      SystemLogView.jscript.appendAttributedString( msg )
      SystemLogView.messages.appendAttributedString( msg )
      NSNotificationCenter.defaultCenter.postNotificationName( 'StoryLogChanged', object: nil )
    end

    def clear
      SystemLogView.messages = NSMutableAttributedString.alloc.initWithString( '' )
      SystemLogView.jscript  = NSMutableAttributedString.alloc.initWithString( '' )
      NSNotificationCenter.defaultCenter.postNotificationName( 'StoryLogChanged', object: nil )
    end

    def create_log_message( message, color=nil )
      color_attribute = '#ffffff'.uicolor
      case color
        when :red
          color_attribute = '#ff0000'.uicolor
        when :green
          color_attribute = '#00ff00'.uicolor
        when :blue
          color_attribute = '#0000ff'.uicolor
        when :yellow
          color_attribute = '#ffff00'.uicolor
        else
          if color.respond_to? 'uicolor'
            color_attribute = color.uicolor
          end
      end
      NSAttributedString.alloc.initWithString( "\n#{message}", attributes: { NSForegroundColorAttributeName => color_attribute } )
    end
  end

  attr_reader :hidden

  def initWithSize( size )
    super.initWithFrame( CGRectMake( 0, 0, size.width, size.height ) ).tap do

      self.center = CGPointMake( size.width / 2.0 , -0.5 * size.height )
      self.backgroundColor = '#000000'.uicolor
      self.alpha = 0.75

      @text_view = UITextView.alloc.initWithFrame( CGRectMake( 0, 44, size.width, size.height - 44 ), textContainer: nil ).tap do |text|
        text.backgroundColor = '#000000'.uicolor( 0.0 )
        text.textColor = '#ffffff'.uicolor
        text.attributedText = SystemLogView.messages
        text.scrollEnabled = true
        text.editable = false
      end

      @mode_switch = UIButton.buttonWithType( :custom.uibuttontype )
      @mode_switch.setTitle( 'log: jscript', forState: :normal.uicontrolstate )
      @mode_switch.addTarget( self, action: 'mode_changed:', forControlEvents: :touch.uicontrolevent )
      @mode_switch.frame = [ [ 0, 20 ], [ 60, 20 ] ]
      @mode_switch.titleLabel.font = UIFont.italicSystemFontOfSize( 12.0 )
      @mode_switch.titleLabel.textAlignment = :left.nstextalignment

      @hide_switch = UIButton.buttonWithType( :custom.uibuttontype )
      @hide_switch.setTitle( 'X', forState: :normal.uicontrolstate )
      @hide_switch.frame = [ [ size.width - 40, 20 ], [ 40, 20 ] ]
      @hide_switch.titleLabel.font = UIFont.italicSystemFontOfSize( 12.0 )
      @hide_switch.titleLabel.textAlignment = :left.nstextalignment
      @hide_switch.addTarget( self, action: 'hide', forControlEvents: :touch.uicontrolevent )

      @hidden = true
      @mode = :jscript

      addSubview( @text_view )
      addSubview( @mode_switch )
      addSubview( @hide_switch )

      NSNotificationCenter.defaultCenter.addObserver( self, selector: 'log_changed:', name: 'StoryLogChanged', object: nil )
    end
  end

  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver( self, name: 'StoryLogChanged', object: nil )
    super
  end

  def show
    if @hidden
      visibleCenter = CGPointMake( self.superview.center.x, self.superview.center.y )
      UIView.animateWithDuration( 0.75, animations: lambda { self.center = visibleCenter }, completion: nil )
      @hidden = false
    end
  end

  def hide
    unless @hidden
      hiddenCenter = CGPointMake( self.superview.center.x, self.superview.center.y - self.bounds.size.height )
      UIView.animateWithDuration( 0.75, animations: lambda { self.center = hiddenCenter }, completion: nil )
      @hidden = true
    end
  end

  def toggle
    if @hidden
      show
    else
      hide
    end
  end

  def log_changed( _ )
      Dispatch::Queue.main.async do
        if @mode == :jscript
          @text_view.attributedText = SystemLogView.jscript
        else
          @text_view.attributedText = SystemLogView.messages
        end

        # adjust scrolling
        #bottom = CGPointMake( 0, @text_view.contentSize.height - @text_view.bounds.size.height + @text_view.contentInset.bottom )
        #@text_view.setContentOffset( bottom, animated: false )
        @text_view.scrollRangeToVisible( NSMakeRange( @text_view.attributedText.length - 1, 1 ) )
      end
  end

  def mode_changed( _ )
    if @mode == :jscript
      @mode = :all
      @mode_switch.setTitle( 'log: all', forState: :normal.uicontrolstate )
    else
      @mode = :jscript
      @mode_switch.setTitle( 'log: jscript', forState: :normal.uicontrolstate )
    end

    log_changed( self )
  end
end

