module Babbo
  module JSBridge
    # Base class for all JavaScript proxy objects
    class Generic
      def initialize( story_node )
        #PM::logger.debug( "creating new #{self.class} -> #{story_node}" )
        @node = story_node
      end

      # Return the nodes path (node = JSON Document element)
      def name()
        @node.path
      end

      def moveResize( args )
        size_x = args['width']
        size_y = args['height']
        pos_x  = args['x']
        pos_y  = args['y']
        sec    = args['duration']

        PM::logger.info( "In Args: #{size_x}, #{size_y}, #{pos_x}, #{pos_y}, #{sec}")
        # x.calc_size( size, obj_size )
        # x.calc_position( position, size )
        screen = UIScreen.mainScreen.bounds
        scale  = UIScreen.mainScreen.scale

        PM::logger.info( "old size: #{@node.size.width}, #{@node.size.height}")
        # convert from 0.0 => 1.0 size range to actual pixels
        # for this screen.size has to be multiplied by the correct scale
        new_size = CGSizeMake( size_x, size_y )
        px_size = CGSizeMake( screen.size.width * scale * new_size.width,
                              screen.size.height * scale * new_size.height )

        PM::logger.info( "px_size new: #{px_size.width}, #{px_size.height}")
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
        group = SKAction.group( [ move_action, size_action ] )

        @node.scene_node.runAction( group )
      end
    end
  end
end

