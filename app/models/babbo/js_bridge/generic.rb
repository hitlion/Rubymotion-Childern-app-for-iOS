module Babbo
  module JSBridge
    # Base class for all JavaScript proxy objects
    class Generic
      def initialize( story_node )
        #mp_d( "creating new #{self.class} -> #{story_node}" )
        @node = story_node
      end

      # Return the nodes path (node = JSON Document element)
      def name()
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

      def layer( args )
        new_z = args['l'] || @snode.scene_node.zPosition
        @node.scene_node.zPosition = new_z
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
    end
  end
end

