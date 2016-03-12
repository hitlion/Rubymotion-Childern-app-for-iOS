class StoryEditorChangeScreenBox < UIView
  def initWithFrame( frame )
    super.tap do
      @hidden = false

      @new_level = 0
      @new_screen = 0

      rmq(self).stylesheet = StoryEditorChangeScreenBoxStylesheet
      rmq(self).apply_style(:root)

      append(UIView, :background)
      level_box = append!(UIView, :level_box)
      screen_box = append!(UIView, :screen_box)

      level_box.append(UILabel, :level_label)
      level_box.append(UIStepper, :level_stepper).on(:change) do |sender, _|
        @new_level = sender.value.to_i
        update_display_values
      end
      screen_box.append(UILabel, :screen_label)
      screen_box.append(UIStepper, :screen_stepper).on(:change) do |sender, _|
        @new_screen = sender.value.to_i
        update_display_values
      end
      append(UIButton, :ok_button).on(:tap) do
        rmq.screen.show_scene_with_level(rmq(:level_stepper).get.value.to_i, screen: rmq(:screen_stepper).get.value.to_i)
        hide
      end
      append(UIButton, :cancel_button).on(:tap) do
        hide
      end

    end
  end

  def hide
    return if @hidden
    @hidden = true

    rmq(self).animate(duration: 0.5, animations: ->(q){
        q.move top: device.screen_height + 20
    })

    # disable touch capturing
    off
  end

  def show
    return unless @hidden
    @hidden = false

    @new_level = rmq.screen.level.to_i
    @new_screen = rmq.screen.screen.to_i

    rmq(self).show
    if(rmq.screen)
      @new_level = rmq.screen.level.to_i
      @new_screen = rmq.screen.screen.to_i
    end

    rmq(self).animate(duration: 0.5, animations: ->(q){
      q.move from_bottom: 20
    })

    update_display_values

    # catch taps on this view to prevent accidential hiding
    on(:tap) { |_, _| }
  end

  def update_display_values
    return if  @new_level.nil? || @new_screen.nil?
    rmq(:level_label).get.text = 'Level: %d' % @new_level.to_i
    rmq(:level_stepper).get.value = @new_level
    rmq(:screen_label).get.text = 'Screen: %d' % @new_screen.to_i
    rmq(:screen_stepper).get.value = @new_screen
  end
end

