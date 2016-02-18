class StoryEditorChangeScreenBox < UIView
  def initWithFrame( frame )
    super.tap do
      @hidden = false

      @editor = nil
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
        @editor.show_scene_with_level(rmq(:level_stepper).get.value.to_i, screen: rmq(:screen_stepper).get.value.to_i)
        hide
      end
      append(UIButton, :cancel_button).on(:tap) do
        hide
      end

    end
  end

  def set_editor(editor)
    @editor = editor
    @new_level = editor.level.to_i
    @new_screen = editor.screen.to_i
    update_display_values
  end

  def hide
    return if @hidden
    @hidden = true

    rmq(self).hide

    # disable touch capturing
    off
  end

  def show
    return unless @hidden
    @hidden = false

    rmq(self).show
    if(@editor)
      @new_level = @editor.level.to_i
      @new_screen = @editor.screen.to_i
    end


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

