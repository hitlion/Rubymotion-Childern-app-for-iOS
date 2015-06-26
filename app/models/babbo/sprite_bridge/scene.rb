module Babbo
  module SpriteBridge
    class Scene < SKScene
      attr_accessor :document

      def didMoveToView( view )
        @swipe ||= UISwipeGestureRecognizer.alloc.initWithTarget( self, action: 'on_gesture_detected:' )
        @swipe.numberOfTouchesRequired = 1
        @swipe.direction = UISwipeGestureRecognizerDirectionUp   |
                           UISwipeGestureRecognizerDirectionDown |
                           UISwipeGestureRecognizerDirectionLeft |
                           UISwipeGestureRecognizerDirectionRight
        @swipe.reset

        @tap ||= UITapGestureRecognizer.alloc.initWithTarget( self, action: 'on_gesture_detected:' )
        @tap.numberOfTouchesRequired = 1
        @tap.numberOfTapsRequired = 1
        @tap.requireGestureRecognizerToFail( @swipe )

        #self.scaleMode = SKScaleModeFill

        view.addGestureRecognizer( @swipe )
        view.addGestureRecognizer( @tap )
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
    end
  end
end

