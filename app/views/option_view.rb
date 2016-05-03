class OptionView < UIView

  attr_accessor :delegate

  def initWithFrame( frame )
    super.tap do

      @hidden = false

      if device.iphone?
        rmq(self).stylesheet = OptionViewIPhoneStylesheet
      else
        rmq(self).stylesheet = OptionViewTabletStylesheet
      end

      rmq(self).apply_style(:root)

      append(UIView, :layer).on(:tap) do
        self.hide
        if @delegate
          @delegate.tabletOptionViewClosed(self) if @delegate.respond_to? 'tabletOptionViewClosed:'
        end
      end

      options = append!(UIView, :option_background)
      options.append(UIImageView, :image)
      options.append(UILabel, :name)
      options.append(UIButton, :button_1).on(:tap) do
        restore
      end

      #options.append(UIButton, :button_2).on(:tap) do
      #  about_us
      #end

      options.append(UIImageView, :logo)
      options.append(UILabel, :version)
    end
  end

  def hidden?
    return @hidden
  end

  def show?
    return !@hidden
  end

  def show
    return unless @hidden
    @hidden = false
    rmq(self).show
    rmq(self).animate(duration: 0.5, animations: ->(q){
      q.move from_right: 0
    })

    # catch taps on this view to prevent accidential hiding
    on(:tap) { |_, _| }
  end

  def hide
    return if @hidden
    @hidden = true
    rmq(self).animate(duration: 0.5, animations: ->(q){
      q.move from_right: -1 * self.frame.size.width
    })

    # disable touch capturing
    off
  end

  def restore
    BabboShop.get.restore_purchases
  end

  def about_us

  end
end