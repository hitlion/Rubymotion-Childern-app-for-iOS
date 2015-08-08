module Babbo
  module SpriteBridge
    class Proxy < Object
      def initialize()
      end

      def create_sknode()
      end

      protected

      # calculate the correct pixel size from a { 0.0...1.0 } range
      def calc_size( size, obj_size=UIScreen.mainScreen.bounds.size )
        #screen = UIScreen.mainScreen.bounds
        scale  = UIScreen.mainScreen.scale

        # convert from 0.0 => 1.0 size range to actual pixels
        # for this screen.size has to be multiplied by the correct scale
        CGSizeMake( obj_size.width * scale * size.width,
                    obj_size.height * scale * size.height )
      end

      # calculate the correct pixel position from a { 0.0...1.0 } range
      # taking into account the flipped / partially centered SpriteKit
      # coordinate system.
      def calc_position( pos, size=nil )
        screen = UIScreen.mainScreen.bounds
        scale  = UIScreen.mainScreen.scale

        px_pos  = CGPointMake( screen.size.width * scale * pos.x,
                                  screen.size.height * scale * pos.y )

        unless size.nil?
          px_size = calc_size( size )

          # SKNodes have their coordinates relative to the center point
          # adjust x/y with that in mind
          px_pos.x += px_size.width / 2.0
          px_pos.y += px_size.height / 2.0
        end

        # SKScene has a bottom-up coordinate system so we need to
        # subtract the y position from the (scaled) screen height
        [ px_pos.x,
          screen.size.height * scale - px_pos.y ]
      end
    end
  end
end

