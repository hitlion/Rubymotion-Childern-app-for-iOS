module Babbo
  module JSBridge
    # Base class for all JavaScript proxy objects
    class Generic
      def initialize( story_node )
        #mp_d( "creating new #{self.class} -> #{story_node}" )
        @node = story_node
      end

      # Return the nodes path (node = JSON Document element)
      def name
        @node.path
      end

      def concurrent( args )
        actions = []

        if args.has_key? 'move' and args.has_key? 'resize'
          # move and resize relate to each other since one
          # influences the outcome of the other so we better
          # calculate them together
          move_resize_args = args.delete('move')
          move_resize_args.merge!( args.delete('resize') )
          args['move_resize'] = move_resize_args
        end

        args.each_pair do |action, aargs|
          next if action == 'duration' or action == 'wait'

          aargs['duration'] = args['duration'] unless aargs.has_key? 'duration'

          case action
            when 'move'
              actions << _move( aargs )
            when 'resize'
              actions << _resize( aargs )
            when 'fade'
              actions << _fade( aargs )
            when 'layer'
              actions << SKAction.runBlock( lambda { self.layer(aargs) } )
            when 'move_resize'
              _move_resize_relative( aargs ).each { |act| actions << act }
            else
              if self.respond_to? action
                actions << SKAction.runBlock( lambda { self.send(action) } )
              end
          end
        end

        unless actions.empty?
          @node.scene_node.runAction( SKAction.group( actions ) )
          if args.has_key? 'wait' and args['wait'] == true
            if args['duration']
              NSThread.sleepForTimeInterval( args['duration'] )
            end
          end
        end
      end

      def move( args )
        @node.scene_node.runAction( _move( args ) )
      end

      def resize( args )
        @node.scene_node.runAction( _resize( args ) )
      end

      def fade( args )
        @node.scene_node.runAction( _fade( args ) )
      end

      def layer( *args )
        if args.empty?
          @node.scene_node.zPosition
        else
          new_z = args.first['l'] || @node.scene_node.zPosition
          @node.scene_node.zPosition = new_z
        end
      end

      def emit( slot_name )
        # FIXME: Am I really OK with that way of accessing the document?
        @node.emit( nil, @node.scene_node.scene.document, slot_name )
      end

      # read-only property-access
      def position_x
        position = _point_for_top_left_position
        ( '%.2f' % _point_from_scene( position ).x ).to_f
      end

      def position_y
        position = _point_for_top_left_position
        ( '%.2f' % _point_from_scene( position ).y ).to_f
      end

      def size_x
        scene = @node.scene_node.scene
        size  = @node.scene_node.size

        ( '%.2f' % ( ( size.width * 100.0 / scene.size.width ) * 0.01 ) ).to_f
      end

      def size_y
        scene = @node.scene_node.scene
        size  = @node.scene_node.size

        ( '%.2f' % ( ( size.height * 100.0 / scene.size.height ) * 0.01 ) ).to_f
      end

      def transparency
        ( '%.2f' % ( 1.0 - @node.scene_node.alpha ) ).to_f
      end

      private # non exported API

      def _fade( args )
        new_alpha = 1.0 - args['alpha']
        sec       = args['duration']

        fade_action = SKAction.fadeAlphaTo( new_alpha, duration: sec )
        fade_action
      end

      def _move( args )
        pos_x  = args['x']
        pos_y  = args['y']
        sec    = args['duration']

        screen = UIScreen.mainScreen.bounds
        scale  = UIScreen.mainScreen.scale

        new_pos = CGPointMake( pos_x, pos_y )
        px_pos  = CGPointMake( screen.size.width * scale * new_pos.x,
                               screen.size.height * scale * new_pos.y )

        # SKNodes have their coordinates relative to the center point
        # adjust x/y with that in mind
        px_pos.x += @node.scene_node.size.width / 2.0
        px_pos.y += @node.scene_node.size.height / 2.0

        # SKScene has a bottom-up coordinate system so we need to
        # subtract the y position from the (scaled) screen height
        move_action = SKAction.moveTo( CGPointMake( px_pos.x, screen.size.height * scale - px_pos.y ), duration: sec )
        move_action
      end

      def _resize( args )
        size_x = args['width']
        size_y = args['height']
        sec    = args['duration']

        # x.calc_size( size, obj_size )
        # x.calc_position( position, size )
        screen = UIScreen.mainScreen.bounds
        scale  = UIScreen.mainScreen.scale

        # convert from 0.0 => 1.0 size range to actual pixels
        # for this screen.size has to be multiplied by the correct scale
        new_size = CGSizeMake( size_x, size_y )
        px_size = CGSizeMake( screen.size.width * scale * new_size.width,
                             screen.size.height * scale * new_size.height )

        # SKScene has a bottom-up coordinate system so we need to
        # subtract the y position from the (scaled) screen height
        size_action = SKAction.resizeToWidth( px_size.width, height: px_size.height, duration: sec )
        size_action
      end

      def _move_resize_relative( args )
        size_x = args['width']
        size_y = args['height']
        pos_x  = args['x']
        pos_y  = args['y']
        sec    = args['duration']

        screen = UIScreen.mainScreen.bounds
        scale  = UIScreen.mainScreen.scale

        # convert from 0.0 => 1.0 size range to actual pixels
        # for this screen.size has to be multiplied by the correct scale
        new_size = CGSizeMake( size_x, size_y )
        px_size = CGSizeMake( screen.size.width * scale * new_size.width,
                             screen.size.height * scale * new_size.height )

        new_pos = CGPointMake( pos_x, pos_y )
        px_pos  = CGPointMake( screen.size.width * scale * new_pos.x,
                              screen.size.height * scale * new_pos.y )

        # SKNodes have their coordinates relative to the center point
        # adjust x/y with that in mind
        px_pos.x += px_size.width / 2.0
        px_pos.y += px_size.height / 2.0

        # SKScene has a bottom-up coordinate system so we need to
        # subtract the y position from the (scaled) screen height
        move_action = SKAction.moveTo( CGPointMake( px_pos.x, screen.size.height * scale - px_pos.y ), duration: sec )
        size_action = SKAction.resizeToWidth( px_size.width, height: px_size.height, duration: sec )
        [ move_action, size_action ]
      end

      def _point_for_top_left_position
        center_pos = @node.scene_node.position
        node_size  = @node.scene_node.size

        # remember: Y increases on the negative axis..
        CGPointMake( center_pos.x - node_size.width / 2.0,
                     center_pos.y + node_size.height / 2.0 )
      end

      def _point_for_center_position( point )
        node_size  = @node.scene_node.size

        # remember: Y increases on the negative axis..
        CGPointMake( point.x + node_size.width / 2.0,
                     point.y - node_size.height / 2.0 )
      end

      def _point_from_scene( point )
        scene = @node.scene_node.scene
        CGPointMake( 0.01 * ( point.x * 100.0 / scene.size.width ),
                     0.01 * ( ( scene.size.height - point.y ) * 100.0 / scene.size.height ) )
      end

      def _point_to_scene( point )
        scene = @node.scene_node.scene
        CGPointMake( point.x * 100.0 * scene.size.width,
                     point.y * 100.0 * scene.size.height )
      end
    end
  end
end

