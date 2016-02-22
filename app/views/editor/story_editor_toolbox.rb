class StoryEditorToolbox < UIView
  def initWithFrame( frame )
    super.tap do
      @hidden = false
      @edge   = :right
      @editor = nil

      @target = nil
      @node   = nil

      rmq(self).stylesheet = StoryEditorToolboxStylesheet
      rmq(self).apply_style(:root)

      snap_to_right_edge(frame, true)

      append(UIView, :background_layer)

      append(UIView, :editable_object_table)

      @object_name_label = append!(UILabel, :object_name_label)

      append(UIButton, :move_object).on(:tap) do
        @editor.move_object
      end

      append(UIButton, :edit_object).on(:tap) do
        @editor.edit_object
      end

      append(UIButton, :change_screen).on(:tap) do
        @editor.change_screen
      end

      append(UIButton, :close_editor).on(:tap) do
        @editor.close_editor
      end
    end
  end

  # need this method because the standard one is broken...?
  def hidden?
    return @hidden
  end

  def set_editor(editor)
    @editor = editor
  end

  def set_target(target, node: n, actions: actions)
    @target = nil
    @node = nil
    @actions = nil

    @target = target
    @node   = n
    @actions = actions

    update_display_values
  end

  def show(avoid_location)
    return unless @hidden
    @hidden = false

    update_display_values

    if avoid_location.x > device.screen_width - self.frame.size.width
      # target to the right, slide in from left
      snap_to_left_edge(self.frame, true)
    else
      # no risk of obscuring the target, prefer right
      snap_to_right_edge(self.frame, true)
    end

    rmq(self).show
    if @edge == :left
      rmq(self).animate(duration: 0.5, animations: ->(q){
        q.move left: 0
      })
    else
      rmq(self).animate(duration: 0.5, animations: ->(q){
        q.move from_right: 0
      })
    end

    # catch taps on this view to prevent accidential hiding
    on(:tap) { |_, _| }
  end

  def hide
    return if @hidden

    @hidden = true
    if @edge == :left
      rmq(self).animate(duration: 0.5, animations: ->(q){
        q.move left: -1 * self.frame.size.width
      })
    else
      rmq(self).animate(duration: 0.5, animations: ->(q){
        q.move from_right: -1 * self.frame.size.width
      })
    end

    # disable touch capturing
    off
  end

  private

  def snap_to_right_edge(frame, off_screen)
    parent_frame = CGRect.new([0, 0], [device.screen_width, device.screen_height])
    parent_frame = self.superview.bounds unless self.superview.nil?

    if off_screen
      self.center = [
        parent_frame.size.width + frame.size.width,
        parent_frame.size.height / 2.0
      ]
    else
      self.center = [
        parent_frame.size.width - frame.size.width / 2.0,
        parent_frame.size.height / 2.0
      ]
    end
    @edge = :right
  end

  def snap_to_left_edge(frame, off_screen)
    parent_frame = CGRect.new([0, 0], [device.screen_width, device.screen_height])
    parent_frame = self.superview.bounds unless self.superview.nil?

    if off_screen
      self.center = [
        -1 * frame.size.width,
        parent_frame.size.height / 2.0
      ]
    else
      self.center = [
        frame.size.width / 2.0,
        parent_frame.size.height / 2.0
      ]
    end
    @edge = :left
  end

  def update_display_values

    if(@target.nil?)
      @object_name_label.text = "Kein Objekt ausgewählt"
      rmq(:edit_object).hide
      rmq(:move_object).hide
    else
      @object_name_label.text = @target.name

      if  @actions[:object_name]  || @actions[:object_content] ||
          @actions[:size_x]       || @actions[:size_y]         ||
          @actions[:transparency] || @actions[:layer]
        rmq(:edit_object).show
      end

      if @actions[:position_x] || @actions[:position_y]
        rmq(:move_object).show
      end
    end
  end
end

