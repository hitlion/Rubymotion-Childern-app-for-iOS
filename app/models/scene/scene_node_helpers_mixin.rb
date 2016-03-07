# The scene module contains all classes used to represent
# the screens composing a story on a device specific UI.
# In this case (iOS): it contains classes to display a story an SpriteKit.
module Scene
  # Common methods used by the various node classes
  module NodeHelpersMixin
    def dealloc
      self.texture = nil if self.is_a? SKSpriteNode
      lp "dealloc -> #{self}"
      super
    end

    # Calculate the pixel size for a node based on a reliative size,
    # reference size and scale mode.
    #
    # @param [CGSize] relative_size The relative size in the range 0.0...1.0.
    # @param [Float] aspect_ratio The width/height ratio used when scaling.
    # @param [Symbol] scale_mode The scale mode used to calculate the size.
    #   supported values are:
    #   * :scale - resize X and Y to exactly match +relative_size+
    #   * :aspect_fit - resize X to match +relative_size+, Y to match the
    #     aspect ratio.
    #   * :aspect_fit_x - same as :aspect_fit
    #   * :aspect_fit_y - resize Y to match +relative_size+, X to match the
    #     aspect ratio.
    # @return [CGSize] A pixel size matching the given constrains
    def calculate_node_size( relative_size, aspect_ratio, scale_mode = :scale )
      case scale_mode
      when :aspect_fit, :aspect_fit_x
        CGSize.new(device.screen_width * relative_size.width,
                   (device.screen_width * relative_size.height) / aspect_ratio)

      when :aspect_fit_y
        CGSize.new((device.screen_width * relative_size.height) / aspect_ratio,
                   device.screen_width * relative_size.height)

      else # defaults to :scale
        CGSize.new(device.screen_width * relative_size.width,
                   device.screen_height * relative_size.height)
      end
    end

    # Calculate the absolute pixel position based on +relative_position+.
    #
    # @param [CGPoint] relative_position The relative scene position in the
    #   range 0.0...1.0
    # @param [CGSize] node_size The size of the node (required for center-
    #   -point correction).
    # @return [CGPoint] A pixel position matching the given constrains.
    def calculate_node_position( relative_position, node_size )
      # NOTE: SpriteKit uses a bottom-left coordinate system
      tmp = CGPoint.new(device.screen_width * relative_position.x,
                        device.screen_height - (device.screen_height * relative_position.y))
      # move the top-left based coordinates to center based versions
      CGPoint.new(tmp.x + node_size.width / 2.0,
                  tmp.y - node_size.height / 2.0)
    end

    # Calculate the relative size of +node_size+ based on the screen
    # dimensions.
    #
    # @param [CGSize] node_size The current size in pixels.
    # @return [CGSize] The relative size in the range 0.0...1.0.
    def calculate_relative_size( node_size )
      CGSize.new(('%.2f' % (node_size.width / device.screen_width)).to_f,
                 ('%.2f' % (node_size.height / device.screen_height)).to_f)
    end

    # Calculate the relative position of +node_position+ based on the
    # screen dimensions.
    #
    # @param [CGPoint] node_position The current center position in pixels.
    # @param [CGSize] node_size The current size in pixels (required for 
    #   top-left offset correction).
    # @return [CGPoint] The relative top-left position in range 0.0...1.0.
    def calculate_relative_position( node_position, node_size )
      tmp = CGPoint.new(node_position.x - node_size.width / 2.0,
                        device.screen_height - (node_position.y + node_size.height / 2.0))

      CGPoint.new(('%.2f' % (tmp.x / device.screen_width)).to_f,
                  ('%.2f' % (tmp.y / device.screen_height)).to_f)
    end
  end
end

