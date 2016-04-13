class StoryEditorEditBox < UIView
  def initWithFrame( frame )
    super.tap do
      @hidden = false
      @edge   = :right

      @target = nil
      @node   = nil

      rmq(self).stylesheet = StoryEditorEditBoxStylesheet
      rmq(self).apply_style(:root)

      snap_to_right_edge(frame, true)

      append(UIView, :background_layer)

      @object_name_label = append!(UILabel, :object_name_label)
      append(UIButton, :edit_name).on(:tap) do |_|
        app.alert(title: 'Name ändern', message: "Neuen Namen eingeben", style: :custom, fields: {input: {placeholder: @target.name}}) do |_, fields|
          unless fields[:input].text.empty?
            @target.name = fields[:input].text
            update_display_values
          end
        end
      end

      append(UIButton, :edit_content).on(:tap) do |_|
        case @target.type
          when :picture
            rmq.screen.present_photo_chooser(WeakRef.new(self))
          when :video
            rmq.screen.present_video_chooser(WeakRef.new(self))
          when :audio
            @new_audio_path = rmq.screen.story_bundle.asset_path_for_new_item_of_type(:audio)
            path = rmq.screen.story_bundle.asset_path(@new_audio_path)
            rmq.screen.record_audio(path, WeakRef.new(self))
        end
      end

      append(UILabel, :resize_width_label)
      append(UISlider, :resize_width_slider).on(:change) do |sender, _|
        unless @target.nil? or @node.nil? or !defined? @node.size
          size = CGSize.new(sender.value, @target.size.height)
          @node.size = @node.calculate_node_size(size, size.width / size.height, @target.resize)
          @node.position = @node.calculate_node_position(@target.position, @node.size)

          @target.size = @node.calculate_relative_size(@node.size)

          update_display_values
        end
      end

      append(UILabel, :resize_height_label)
      append(UISlider, :resize_height_slider).on(:change) do |sender, _|
        unless @target.nil? or @node.nil? or !defined? @node.size
          size = CGSize.new(@target.size.width, sender.value)
          @node.size = @node.calculate_node_size(size, size.width / size.height, @target.resize)
          @node.position = @node.calculate_node_position(@target.position, @node.size)

          @target.size = @node.calculate_relative_size(@node.size)

          update_display_values
        end
      end

      append(UILabel, :layer_select_label)
      append(UIStepper, :layer_select_stepper).on(:change) do |sender, _|
        unless @target.nil? or @node.nil?
          @node.zPosition = 999_800 + sender.value
          @target.layer = sender.value

          update_display_values
        end
      end

      append(UILabel, :transparency_label)
      append(UIStepper, :transparency_stepper).on(:change) do |sender, _|
        unless @target.nil? or @node.nil?
          @node.alpha = 1.0001 - sender.value
          @target.transparency = sender.value

          update_display_values
        end
      end
    end
  end

  def set_target(target, node: n, actions: act)
    component_map = {
      object_name:    [ :edit_name ],
      object_content: [ :edit_content ],
      size_x:         [ :resize_width_label , :resize_width_slider ],
      size_y:         [ :resize_height_label, :resize_height_slider ],
      layer:          [ :layer_select_label , :layer_select_stepper ],
      transparency:   [ :transparency_label , :transparency_stepper ]
    }

    @target = nil
    @node   = nil
    @actions = nil

    @target = target
    @node   = n
    @actions = act
    component_map.map { |_, keys| keys }.flatten.each { |key| rmq(key).hide }

    unless @target.nil?
      components = []
      act.each do |key, _|
        components += component_map[key] if component_map.has_key? key
      end
      components.each do |key|
        rmq(key).show
      end
      # this line produce a crash in the second editor run
      #rmq(*components).distribute(:vertical, margin: 12) unless components.empty?

      update_display_values
    end
  end

  def hidden?
    return @hidden
  end

  def show?
    return !@hidden
  end

  def show(avoid_location)
    return unless @hidden
    @hidden = false

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

  def media_chooser_popup_anchor
    rmq(:edit_content).get
  end

  def photo_available( image, new )
    path = rmq.screen.story_bundle.asset_path_for_new_item_of_type(:picture)
    texture = SKTexture.textureWithImage(image)
    @node.texture = texture

    if(@target.changes[:object_content])
      unless(@target.content == @target.changes[:object_content][:original])
        old_content_path = File.join(rmq.screen.story_bundle.path, @target.content.split('..').last)
        rmq.screen.obsolete_files << old_content_path
      end
    end

    @target.content = path

    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil) if new

    path = rmq.screen.story_bundle.asset_path(path)
    rmq.screen.new_files << path
    UIImagePNGRepresentation(image).writeToFile(path, atomically: true)
  end

  def photo_canceled
  end

  def video_available( media_url, new )
    path = rmq.screen.story_bundle.asset_path_for_new_item_of_type(:video)

    if(@target.changes[:object_content])
      unless(@target.content == @target.changes[:object_content][:original])
        old_content_path = File.join(rmq.screen.story_bundle.path, @target.content.split('..').last)
        rmq.screen.obsolete_files << old_content_path
      end
    end

    @target.content = path
    path = rmq.screen.story_bundle.asset_path(path)

    UISaveVideoAtPathToSavedPhotosAlbum(media_url.fileSystemRepresentation,nil,nil,nil) if new

    File.rename(media_url.fileSystemRepresentation, path)
    rmq.screen.new_files << path
    # reload scene for updating the video node image
    rmq.screen.show_scene(rmq.screen.current_view)
  end

  def video_canceled
  end

  def audio_available( media_url )

    lp "Target: #{@target}"

    if(@target.changes[:object_content])
      unless(@target.content == @target.changes[:object_content][:original])
        old_content_path = File.join(rmq.screen.story_bundle.path, @target.content.split('..').last)
        rmq.screen.obsolete_files << old_content_path
      end
    end
    # FIXME: this should be done by StoryBundle..
    rmq.screen.new_files << File.join(rmq.screen.story_bundle.path, @new_audio_path.split('..').last)
    @target.content = @new_audio_path
  end

  def audio_canceled
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
    return if @target.nil?

    @object_name_label.text = @target.name
    rmq(:resize_width_slider).get.setValue(@target.size.width, animated: false)
    rmq(:resize_height_slider).get.setValue(@target.size.height, animated: false)
    rmq(:layer_select_label).get.text = 'Ebene: %d' % @target.layer
    rmq(:layer_select_stepper).get.value = @target.layer
    rmq(:transparency_label).get.text = 'Transparenz: %.2f' % @target.transparency
    rmq(:transparency_stepper).get.value = @target.transparency

    rmq(:edit_name).hide
    rmq(:edit_content).hide
    rmq(:resize_height_label).hide
    rmq(:resize_width_label).hide
    rmq(:resize_width_slider).hide
    rmq(:resize_height_slider).hide
    rmq(:layer_select_label).hide
    rmq(:layer_select_stepper).hide
    rmq(:transparency_label).hide
    rmq(:transparency_stepper).hide

    if(@actions)
      if @actions[:object_name]
        rmq(:edit_name).show
      end

      if @actions[:object_content]
        rmq(:edit_content).show
      end

      if (@actions[:size_x] && defined?(@node.size))
        rmq(:resize_width_slider).show
        rmq(:resize_width_label).show
      end

      if (@actions[:size_y] && defined?(@node.size))
        rmq(:resize_height_slider).show
        rmq(:resize_height_label).show
      end

      if @actions[:transparency]
        rmq(:transparency_label).show
        rmq(:transparency_stepper).show
      end

      if @actions[:layer]
        rmq(:layer_select_label).show
        rmq(:layer_select_stepper).show
      end
    end
  end
end

