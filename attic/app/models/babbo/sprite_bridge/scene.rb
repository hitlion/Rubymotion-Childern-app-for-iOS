module Babbo
  module SpriteBridge
    class Scene < SKScene
      attr_accessor :document
      attr_accessor :edit_mode

      def initWithSize(size)
        if super
          @edit_mode ||= false
          self
        end
      end

      def edit_mode= (state)
        @edit_mode = state

        unless self.view.nil?
          self.view.removeGestureRecognizer( @swipe_vertical )
          self.view.removeGestureRecognizer( @swipe_left )
          self.view.removeGestureRecognizer( @swipe_right )
          self.view.removeGestureRecognizer( @tap )
          self.view.removeGestureRecognizer( @long_press ) unless @long_press.nil?
          didMoveToView( self.view )
        end
      end

      def didMoveToView( view )
        @swipe_vertical ||= UISwipeGestureRecognizer.alloc.initWithTarget( self, action: 'on_gesture_detected:' )
        @swipe_vertical.numberOfTouchesRequired = 1
        @swipe_vertical.direction = UISwipeGestureRecognizerDirectionUp   |
                                    UISwipeGestureRecognizerDirectionDown
        @swipe_vertical.reset

        @swipe_left ||= UISwipeGestureRecognizer.alloc.initWithTarget( self, action: 'on_gesture_detected:' )
        @swipe_left.numberOfTouchesRequired = 1
        @swipe_left.direction = UISwipeGestureRecognizerDirectionLeft
        @swipe_left.reset

        @swipe_right ||= UISwipeGestureRecognizer.alloc.initWithTarget( self, action: 'on_gesture_detected:' )
        @swipe_right.numberOfTouchesRequired = 1
        @swipe_right.direction = UISwipeGestureRecognizerDirectionRight
        @swipe_right.reset

        @tap ||= UITapGestureRecognizer.alloc.initWithTarget( self, action: 'on_gesture_detected:' )
        @tap.numberOfTouchesRequired = 1
        @tap.numberOfTapsRequired = 1
        @tap.requireGestureRecognizerToFail( @swipe_vertical )
        @tap.requireGestureRecognizerToFail( @swipe_left )
        @tap.requireGestureRecognizerToFail( @swipe_right )

        @double_tap ||= UITapGestureRecognizer.alloc.initWithTarget( self, action: 'on_show_log:' )
        @double_tap.numberOfTouchesRequired = 2
        @double_tap.numberOfTapsRequired = 2
        @double_tap.requireGestureRecognizerToFail( @swipe_vertical )
        @double_tap.requireGestureRecognizerToFail( @swipe_left )
        @double_tap.requireGestureRecognizerToFail( @swipe_right )
        @double_tap.requireGestureRecognizerToFail( @tap )


        view.addGestureRecognizer( @swipe_vertical )
        view.addGestureRecognizer( @swipe_left )
        view.addGestureRecognizer( @swipe_right )
        view.addGestureRecognizer( @tap )
        view.addGestureRecognizer( @double_tap )

        @log_view ||= SystemLogView.alloc.initWithSize( view.size )
        view.addSubview( @log_view )
      end

      def willMoveFromView( view )
        @log_view.removeFromSuperview()
      end

      def audioPlayerDidFinishPlaying(player, successfully: flag )
        if @document.nil?
          mp_e( "Scene '#{self.name}' received a audio done call but has no document!" )
          return
        end

        object = @document.object_for_path( player.babbo_object_id )

        mp_l( "Playback ended for item #{player.babbo_object_id}" )
        unless object.nil?
          object.emit( 'at_end', @document ) if object.respond_to? 'emit:'
        end
      end

      private

      def on_video_done( notification )
        if @document.nil?
          mp_e( "Scene '#{self.name}' received a video done notification but has no document!" )
          return
        end

        player = notification.object
        object = @document.object_for_path( player.babbo_object_id )

        mp_l( "Playback ended for item #{player.babbo_object_id}" )
        unless object.nil?
           object.scene_node.pause if object.scene_node.respond_to? 'pause'
           object.emit( 'at_end', @document ) if object.respond_to? 'emit:'
        end
      end

      def on_gesture_detected( sender )
        mp_l( "on_gesture_detected" )
        if @document.nil?
          mp_e( "Scene '#{self.name}' detected a gesture but have no document!" )
          return
        end

        if sender.state == UIGestureRecognizerStateEnded
          touch_loc = sender.locationInView( sender.view )
          scene_loc = convertPointFromView( touch_loc )

          node = nodeAtPoint( scene_loc )
          object = @document.object_for_path( node.name )

          if sender.is_a? UISwipeGestureRecognizer
            mp_l( "Detected a swipe on '#{node.name}'" )
            object.emit( 'on_swipe', @document ) if object.respond_to? 'emit:'

          elsif sender.is_a? UITapGestureRecognizer
            mp_l( "Detected a tap on '#{node.name}'" )
            object.emit( 'on_click', @document ) if object.respond_to? 'emit:'
          end
        end
      end

      def on_show_log( sender )
          @log_view.show
      end
    end
  end
end

