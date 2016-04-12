class StoryEditorChangeViewBox < UIView
  def initWithFrame( frame )
    super.tap do
      @hidden = false
      @current_view = nil
      @available_views = nil
      @index = nil

      rmq(self).stylesheet = StoryEditorChangeViewBoxStylesheet
      rmq(self).apply_style(:root)

      append(UIView, :background)

      append(UIButton, :back_button).on(:tap) do
        if(@index > 0)
          rmq.screen.show_scene(@available_views[@index - 1])
          update
        end
      end

      append(UILabel, :text_label)

      append(UIButton, :next_button).on(:tap) do
        if(@index < @available_views.count)
          rmq.screen.show_scene(@available_views[@index + 1])
          update
        end
      end

      append(UIButton, :close_button).on(:tap) do
        hide
      end

      #level_box = append!(UIView, :level_box)
      #screen_box = append!(UIView, :screen_box)

      #level_box.append(UILabel, :level_label)
     # level_box.append(UIStepper, :level_stepper).on(:change) do |sender, _|
      #  @new_level = sender.value.to_i
     #    update_display_values
     #  end
     #  screen_box.append(UILabel, :screen_label)
     #  screen_box.append(UIStepper, :screen_stepper).on(:change) do |sender, _|
     #    @new_screen = sender.value.to_i
     #     update_display_values
     #   end
     #   append(UIButton, :ok_button).on(:tap) do
     #     rmq.screen.show_scene_with_level(rmq(:level_stepper).get.value.to_i, screen: rmq(:screen_stepper).get.value.to_i)
     #     hide
     #   end
     #   append(UIButton, :cancel_button).on(:tap) do
     #      hide
      #    end
    end
  end

  def update
    @current_view = rmq.screen.current_view
    @available_views = rmq.screen.editable_views
    @index = @available_views.index(@current_view)

    update_display_values
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

    lp "Show: Teststststs", force_color: :red
    @current_view = rmq.screen.current_view
    @available_views = rmq.screen.editable_views
    @index = @available_views.index(@current_view)
    rmq(self).animate(duration: 0.5, animations: ->(q){
      q.move from_bottom: 20
    })

    update_display_values

    # catch taps on this view to prevent accidential hiding
    on(:tap) { |_, _| }
  end

  def update_display_values
    rmq(:back_button).show
    rmq(:next_button).show

    rmq(:back_button).hide if(@current_view.equal?(@available_views.first))
    rmq(:next_button).hide if(@current_view.equal?(@available_views.last))
  end
end

