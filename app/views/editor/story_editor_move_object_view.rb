class StoryEditorMoveObjectView < UIView
  def initWithFrame( frame )
    super.tap do

      @target = nil
      @node   = nil

      rmq(self).stylesheet = StoryEditorMoveObjectViewStylesheet
      rmq(self).apply_style(:root)

      append(UIView, :background_layer)

      append(UIView, :top_line)
      append(UIView, :bottom_line)
      append(UIView, :left_line)
      append(UIView, :right_line)

      @choose_root = append!(UIView, :choose_root)

      @choose_root.append(UIView, :choose_background)

      @choose_root.append(UIButton, :accept_button).on(:tap) do
        target_x = (@node.position.x - @node.size.width / 2) / device.screen_width
        target_y = (device.screen_height - (@node.position.y + @node.size.height / 2 )) / device.screen_height
        @target.position = CGPointMake(target_x, target_y)
        lp @target.position
        lp @node.position
        self.hide
      end

      @choose_root.append(UIButton, :deny_button).on(:tap) do
        @node.position = @old_pos
        self.hide
      end

      snap_to_right_edge(@choose_root, true)

    end
  end

  def touchesMoved(touches, withEvent: event)
    super

    touch = event.allTouches.anyObject
    location = touch.locationInView(self)
    prev_location = touch.previousLocationInView(self)

    move_x = 0.0
    move_y = 0.0

    move_x = location.x - prev_location.x
    move_y = location.y - prev_location.y

    x = @node.position.x
    y = @node.position.y

    @node.position = CGPointMake(x+move_x, y-move_y)
  end

  def touchesEnded(touches, withEvent: event)
    super

  end

  def show(avoid_location)

    rmq.screen.player.gestureRecognizers.each do |rec|
      rec.enabled = false
    end

    if avoid_location.x > device.screen_width - @choose_root.frame.size.width
      # target to the right, slide in from left
      snap_to_left_edge(@choose_root, true)
    else
      # no risk of obscuring the target, prefer right
      snap_to_right_edge(@choose_root, true)
    end

    rmq(self).show
    self.bringSubviewToFront(@choose_root)

    # catch taps on this view to prevent accidential hiding
    on(:tap) { |_, _| }
  end

  def hide
    rmq(self).hide

    if(@node)
      @node.hidden = false
    end

    rmq.screen.player.gestureRecognizers.each do |rec|
      rec.enabled = true
    end
    # disable touch capturing
    off
  end

  def set_target(target, node: n, actions: actions)
    @target = nil
    @node = nil
    @actions = nil

    @target = target
    @node   = n
    @actions = actions

    lp @target.position
    lp @node.position
    @old_pos = @node.position
  end

  def snap_to_right_edge(view, off_screen)
    parent_frame = CGRect.new([0, 0], [device.screen_width, device.screen_height])
    parent_frame = self.superview.bounds unless self.superview.nil?

    if off_screen
      view.center = [
          parent_frame.size.width - view.frame.size.width / 2.0,
          parent_frame.size.height - view.frame.size.height / 2.0
      ]
    else
      view.center = [
          parent_frame.size.width - view.frame.size.width / 2.0,
          parent_frame.size.height - view.frame.size.height / 2.0
      ]
    end
    @edge = :right
  end

  def snap_to_left_edge(view, off_screen)
    parent_frame = CGRect.new([0, 0], [device.screen_width, device.screen_height])
    parent_frame = self.superview.bounds unless self.superview.nil?

    if off_screen
      view.center = [
          view.frame.size.width / 2.0,
          parent_frame.size.height - view.frame.size.height / 2.0
      ]
    else
      view.center = [
          view.frame.size.width / 2.0,
          parent_frame.size.height - view.frame.size.height / 2.0
      ]
    end
    @edge = :left
  end
end

