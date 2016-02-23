class StoryEditorToolbox < UIView
  def initWithFrame( frame )
    super.tap do
      @hidden = false
      @edge   = :right
      @editor = nil

      @target = nil
      @node   = nil
      @editable_objects = []

      rmq(self).stylesheet = StoryEditorToolboxStylesheet
      rmq(self).apply_style(:root)

      snap_to_right_edge(frame, true)

      append(UIView, :background_layer)

      table_background = append(UIView, :table_background)

      @object_table = table_background.append(UITableView, :editable_object_table).get
      @object_table.dataSource = self
      @object_table.delegate = self

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

    if(@editor.editable)
      @editable_objects = []
      @editor.editable.map(&:first).each do |key, value|
        @editable_objects << key
      end

      @object_table.reloadData
    end

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

      if(@actions)
        if  @actions[:object_name]  || @actions[:object_content] ||
            @actions[:size_x]       || @actions[:size_y]         ||
            @actions[:transparency] || @actions[:layer]
          rmq(:edit_object).show
        end

        if @actions[:position_x] || @actions[:position_y]
          rmq(:move_object).show
        end
      else
        rmq(:edit_object).hide
        rmq(:move_object).hide
      end
    end
  end

  def tableView(view, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"

    cell = view.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: @reuseIdentifier)
    end

    if(@editor.player.node_for_path(@editable_objects[indexPath.row]))
      cell.textLabel.text = @editor.story_bundle.object_for_path(@editable_objects[indexPath.row]).name
    else
      cell.textLabel.text = "Error: no source found"
    end

    cell
  end

  def tableView(view, numberOfRowsInSection: section)
    count = 0

    if(@editor)
      count = @editor.editable.count
    end

    count
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    #tableView.deselectRowAtIndexPath(indexPath, animated: true)

    @editor.update_toolbox_selected_node(@editable_objects[indexPath.row])
  end
end

