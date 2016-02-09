class StoryEditorToolbox < UIView
  def initWithFrame( frame )
    super.tap do
      @hidden = false
      @edge   = :right

      @target = nil
      @node   = nil

      rmq(self).stylesheet = StoryEditorToolboxStylesheet
      rmq(self).apply_style(:root)

      snap_to_right_edge(frame, true)


      append(UIView, :background_layer)
      append(UIImageView, :background_ornament_right)
      append(UIImageView, :background_ornament_left)

      append(UILabel, :object_name_label)
      append(UIButton, :edit_name).on(:tap) do |_|
        app.alert(title: 'Name ändern', style: :custom, fields: {input: {placeholder: @target.name}}) do |_, fields|
          unless fields[:input].text.empty?
            @target.name = fields[:input].text
            update_display_values
          end
        end
      end

      append(UIButton, :edit_content).on(:tap) do |_|
        case @target.type
        when :picture
          rmq.screen.present_photo_chooser
        when :video
          rmq.screen.present_video_chooser
        when :audio
          path = rmq.screen.bundle.asset_path_for_new_item_of_type(:audio)
          rmq.screen.present_audio_recorder(path)
        end
      end

      append(UILabel, :resize_width_label)
      append(UISlider, :resize_width_slider).on(:change) do |sender, _|
        unless @target.nil? or @node.nil?
          size = CGSize.new(sender.value, @target.size.height)
          @node.size = @node.calculate_node_size(size, size.width / size.height, @target.resize)
          @node.position = @node.calculate_node_position(@target.position, @node.size)

          @target.size = @node.calculate_relative_size(@node.size)

          update_display_values
        end
      end

      append(UILabel, :resize_height_label)
      append(UISlider, :resize_height_slider).on(:change) do |sender, _|
        unless @target.nil? or @node.nil?
          size = CGSize.new(@target.size.height, sender.value)
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

    @target = target
    @node   = n
    component_map.map { |_, keys| keys }.flatten.each { |key| rmq(key).hide }

    unless @target.nil?
      components = []

      act.each do |key, _|
        components += component_map[key] if component_map.has_key? key
      end

      components.each do |key|
        rmq(key).show
      end

      rmq(*components).distribute(:vertical, margin: 12) unless components.empty?

      update_display_values
    end
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
      rmq(:background_ornament_left).hide
      rmq(:background_ornament_right).show
      rmq(self).animate(duration: 0.5, animations: ->(q){
        q.move left: 0
      })
    else
      rmq(:background_ornament_left).show
      rmq(:background_ornament_right).hide
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

  def photo_available( image )
    path = rmq.screen.bundle.asset_path_for_new_item_of_type(:picture)
    texture = SKTexture.textureWithImage(image)
    @node.texture = texture
    @target.content = path

    path = rmq.screen.bundle.asset_path(path)
    UIImagePNGRepresentation(image).writeToFile(path, atomically: true)
  end

  def photo_canceled
  end

  def video_available( media_url )
    path = rmq.screen.bundle.asset_path_for_new_item_of_type(:video)
    # TODO: update @node?
    @target.content = path

    path = rmq.screen.bundle.asset_path(path)
    File.rename(media_url.fileSystemRepresentation, path)
  end

  def video_canceled
  end

  def audio_available( media_url )
    # FIXME: this should be done by StoryBundle..
    @target.content = media_url.gsub(/^.*\/contents/, '../contents')
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

    rmq(:object_name_label).get.text = @target.name
    rmq(:resize_width_slider).get.setValue(@target.size.width, animated: false)
    rmq(:resize_height_slider).get.setValue(@target.size.height, animated: false)
    rmq(:layer_select_label).get.text = 'Ebene: %d' % @target.layer
    rmq(:layer_select_stepper).get.value = @target.layer
    rmq(:transparency_label).get.text = 'Transparenz: %.2f' % @target.transparency
    rmq(:transparency_stepper).get.value = @target.transparency
  end
end

