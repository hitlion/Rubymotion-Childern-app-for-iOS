module Babbo
  module SpriteBridge
    class EditorScene < SKScene
      attr_accessor :document, :tap_delegate

      def initWithSize(size)
        super.tap do
          self.backgroundColor = '#ffffff'.uicolor
        end
      end

      def didMoveToView( view )

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
        @tap.requireGestureRecognizerToFail( @swipe_left )
        @tap.requireGestureRecognizerToFail( @swipe_right )

        view.addGestureRecognizer( @swipe_left )
        view.addGestureRecognizer( @swipe_right )
        view.addGestureRecognizer( @tap )
      end

      def audioPlayerDidFinishPlaying(player, successfully: flag )
      end

      private

      def on_video_done( notification )
      end

      def on_gesture_detected( sender )
        if @document.nil?
          mp_e( "Scene '#{self.name}' detected a gesture but have no document!" )
          return
        end

        if sender.state == UIGestureRecognizerStateEnded
          touch_loc = sender.locationInView( sender.view )
          scene_loc = convertPointFromView( touch_loc )

          node = nodeAtPoint( scene_loc )
          #object = @document.object_for_path( node.name )

          if sender.is_a? UISwipeGestureRecognizer
            mp_l( "Detected a swipe on '#{node.name}'" )

            target    = nil
            screen_id = self.name[/^:level\[\d+\]:screen\[(\d+)\]/, 1] || '1'
            level_id  = self.name[/^:level\[(\d+)\]:screen\[\d+\]/, 1] || '1'

            case sender.direction
              when UISwipeGestureRecognizerDirectionLeft
                mp_d( "Left swipe" )
                target = @document.object_for_path( ":level[#{level_id}]:screen[#{screen_id.to_i + 1}]" )
                if target.nil?
                  target = @document.object_for_path( ":level[#{level_id.to_i + 1}]:screen[1]")
                end

              when UISwipeGestureRecognizerDirectionRight
                mp_d( "Right swipe" )
                mp_d "Try: :level[#{level_id}]:screen[#{screen_id.to_i - 1}]"
                target = @document.object_for_path( ":level[#{level_id}]:screen[#{screen_id.to_i - 1}]" )
                if target.nil?
                  mp_d "Try: :level[#{level_id.to_i - 1}]:screen[#{screen_id}]"
                  target = @document.object_for_path( ":level[#{level_id.to_i - 1}]:screen[1]")
                end
            end

            unless target.nil?
              mp_l( "Switch to: #{target.path}" )
              StoryPlayerScreen.active_instance.show_scene( target.path )
            end
          elsif sender.is_a? UISwipeGestureRecognizer
            mp_l( "Detected a swipe on '#{node.name}'" )

          elsif sender.is_a? UITapGestureRecognizer
            mp_l( "Detected a tap on '#{node.name}'" )

            if @tap_delegate.respond_to? :'scene_tapped_at_location:with_object:'
               @tap_delegate.scene_tapped_at_location( scene_loc, with_object: node.name )
            end
          end
        end
      end
    end
  end
end

