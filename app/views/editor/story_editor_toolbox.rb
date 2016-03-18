class StoryEditorToolbox < UIView
  def initWithFrame( frame )
    super.tap do
      @hidden = false
      @edge   = :right

      @target = nil
      @node   = nil
      @editable_objects = []

      rmq(self).stylesheet = StoryEditorToolboxStylesheet
      rmq(self).apply_style(:root)

      snap_to_right_edge(frame, true)

      append(UIView, :background_layer)

      append(UILabel, :label)

      table_background = append(UIView, :table_background)

      @object_table = table_background.append(UITableView, :editable_object_table).get
      @object_table.dataSource = self
      @object_table.delegate = self

      @object_name_label = append!(UILabel, :object_name_label)

      append(UIButton, :move_object).on(:tap) do
        rmq.screen.move_object
      end

      append(UIButton, :edit_object).on(:tap) do
        rmq.screen.edit_object
      end

      append(UIButton, :change_view).on(:tap) do
        rmq.screen.change_view
      end

      append(UIButton, :close_editor).on(:tap) do
        rmq.screen.close_editor
      end

    end
  end


  # need this method because the standard one is broken...?
  def hidden?
    return @hidden
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

    rmq.screen.player.gestureRecognizers.each do |rec|
      rec.enabled = false
    end

    @editable_objects = []

    rmq.screen.editable.map(&:first).each do |key, value|
      @editable_objects << key
    end

    @object_table.reloadData

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

    rmq.screen.player.gestureRecognizers.each do |rec|
      rec.enabled = true
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

    if(rmq.screen.editable_views.count < 2)
      rmq(:change_view).hide
    else
      rmq(:change_view).show
    end

    rmq(:edit_object).hide
    rmq(:move_object).hide

    if(@target.nil?)
      @object_name_label.text = "Kein Objekt ausgewählt"
    else
      if(@actions)
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

  def tableView(view, cellForRowAtIndexPath: indexPath)

    @reuseIdentifier ||= "CELL_IDENTIFIER"

    cell = view.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: @reuseIdentifier)
    end

    cell.textLabel.font = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:medium))
    cell.textLabel.adjustsFontSizeToFitWidth = true
    if(rmq.screen.player.node_for_path(@editable_objects[indexPath.row]))
      cell.textLabel.text = rmq.screen.story_bundle.object_for_path(@editable_objects[indexPath.row]).name
    else
      cell.textLabel.text = "Error: no source found"
    end

    cell
  end

  def tableView(view, heightForRowAtIndexPath: path)
    height = TTUtil.get_font_size(:medium) + 10
  end

  def tableView(view, numberOfRowsInSection: section)
    count = 0

    if(rmq.screen)
      count = rmq.screen.editable.count
    end

    count
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    #tableView.deselectRowAtIndexPath(indexPath, animated: true)
    rmq.screen.update_toolbox_selected_node(@editable_objects[indexPath.row])
  end
end

