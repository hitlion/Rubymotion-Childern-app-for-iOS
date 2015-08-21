module JavaScript
  # This module defines most of the common methods
  # exported by the other javascript proxy classes.
  module Common
    include Scene::NodeHelpersMixin

    attr_accessor :node

    # @return [Double] The targets relative X position.
    def position_x
      calculate_relative_position(node.position, node.size).x
    end

    # @return [Double] The targets relative Y position.
    def position_y
      calculate_relative_position(node.position, node.size).y
    end

    # @return [Double] The targets relative width.
    def size_x
      calculate_relative_size(node.size).width
    end

    # @return [Double] The targets relative height.
    def size_y
      calculate_relative_size(node.size).height
    end

    # @return [Double] The targets layer.
    def layer
      format('%.2f', node.zPosition).to_f
    end

    # @return [Double] The targets transparency
    def transparency
      format('%.2f', 1.0001 - node.alpha).to_f
    end

    def name
      node.name || 'undef'
    end

    # Move the target to a new position
    #
    # @param [Hash<String,Double>] args The JavaScript arguments.
    # @option args [Double] x The desired X position (range: 0.0...1.0)
    # @option args [Double] y The desired Y position (range: 0.0...1.0)
    # @option args [Double] duration The animation duration in seconds.
    def move( args )
      args = Hash.symbolicate(args)
      if args[:x] && args[:y] && args[:duration]
        action = do_move(CGPoint.new(args[:x], args[:y]), args[:duration])
        node.runAction(action) unless action.nil?
      end
    end

    # Resize the target.
    #
    # @param [Hash<String,Double>] args The JavaScript arguments.
    # @option args [Double] width The desired width (range: 0.0...1.0)
    # @option args [Double] hight The desired height (range: 0.0...1.0)
    # @option args [Double] duration The animation duration in seconds.
    def resize( args )
      args = Hash.symbolicate(args)
      if args[:width] && args[:height] && args[:duration]
        action = do_resize(CGSize.new(args[:width], args[:height]), duration)
        node.runAction(action) unless action.nil?
      end
    end

    # Change the targets transparency.
    #
    # @param [Hash<String,Double>] args The JavaScript arguments.
    # @option args [Double] alpha The desired transparency (range: 0.0...1.0)
    # @option args [Double] duration The animation duration in seconds.
    def fade( args )
      args = Hash.symbolicate(args)
      if args[:alpha] && args[:duration]
        action = do_fade(args[:alpha], duration)
        node.runAction(action) unless action.nil?
      end
    end

    # Change the targets layer.
    #
    # @param [Hash<String,Double>] args The JavaScript arguments.
    # @option args [Double] layer The desired layer (range: 0.0...1.0)
    # @option args [Double] duration The animation duration in seconds.
    def layer( args )
      args = Hash.symbolicate(args)
      if args[:layer] && args[:duration]
        action = do_layer(args[:layer], duration)
        node.runAction(action) unless action.nil?
      end
    end

    # Perform a list of actions concurrently.
    # This method expects a Hash of actions to perform with the
    # hash keys being the action names and the hash values bein
    # hashes themself containing the actions arguments.
    #
    # @example
    #   concurrent({ move: {x: 0.5, y: 0.5}, duration: 1.0 })
    #
    # @param [Hash<Hash,Hash<String, Double>>] args The JavaScript arguments.
    def concurrent( args )
      actions = []
      args = Hash.symbolicate(args)
      duration = args[:duration] || 1.0
      wait     = args[:wait] || false

      if args.has_key? :move and args.has_key? :resize
        # combine move and resize in continious blocks
        args[:move_resize] = args[:move].merge(args[:resize])
        args.delete(:move)
        args.delete(:resize)
      end

      args.each_pair do |k, v|
        next if [:duration, :wait].include? k
        vargs = Hash.symbolicate(v)

        case k
        when :move
          next if vargs[:x].nil? || vargs[:y].nil?

          actions << do_move(CGPoint.new(vargs[:x], vargs[:y]),
                             vargs[:duration] || duration)

        when :resize
          next if vargs[:width].nil? || vargs[:height].nil?

          acctions << do_resize(CGSize.new(vargs[:width], vargs[:height]),
                                vargs[:duration] || duration)

        when :fade
          next if vargs[:alpha].nil?

          actions << do_fade(vargs[:alpha], vargs[:duration] || 1.0)

        when :layer
          next if vargs[:layer].nil?

          actions << do_layer(vargs[:layer], vargs[:duration] || 1.0)

        when :move_resize
          next if vargs[:x].nil? || vargs[:y].nil? ||
                  vargs[:width].nil? || vargs[:height].nil?

          actions << do_move_resize(CGPoint.new(vargs[:x], vargs[:y]),
                                    CGSize.new(vargs[:width], vargs[:height]),
                                    vargs[:duration] || 1.0)

        when :start, :stop, :pause, :restart
          if self.respond_to? k
            actions << SKAction.customActionWithDuraction(duration,
                        action: -> (_, time){ self.send(k) if time >= duration })
          end
        end
      end

      node.runAction(SKAction.group(actions))
      NSThread.sleepForTimeInterval(duration) unless wait == false
    end

    # Trigger +slot+ on the receiver.
    #
    # @param [String] slot The slot name to call.
    def emit( slot )
      JavaScript::Runtime.call_slot(node.name, slot)
    end

    private

    # Change the targets position over a given duration.
    #
    # @param [CGPoint] target_pos The desired position (range: x/y: 0.0...1.0).
    # @param [Double] duration The animation duration in seconds.
    def do_move( target_pos, duration )
      pos = calculate_node_position(target_pos, node.size)
      SKAction.moveTo(pos, duration: duration || 1.0)
    end

    # Change the targets size over a given duration.
    #
    # @param [CGSize] target_size The desired size (range: w/h: 0.0...1.0).
    # @param [Double] duration The animation duration in seconds.
    # @return [SKAction] A matching +SKAction+.
    def do_resize( target_size, duration )
      size = calculate_node_size(target_size,
                                 node.size.width / node.size.height)
      SKAction.resizeToWidth(size.width,
                             height: size.height,
                             duration: duration || 1.0)
    end

    # Change the targets transparency over a given duration.
    #
    # @param [Double] target_alpha The desired alpha (range: 0.0...1.0).
    # @param [Double] duration The animation duration in seconds.
    # @return [SKAction] A matching +SKAction+.
    def do_fade( target_alpha, duration )
      SKAction.fadeAlphaTo(1.001 - target_alpha, duration: duration || 1.0)
    end

    # Change the targets layer after a given duration.
    #
    # @param [Double] target_layer The new layer (z-position) to move the
    #   target to.
    # @param [Double] duration The animation duration in seconds.
    # @return [SKAction] A matching +SKAction+.
    def do_layer( target_layer, duration )
      SKAction.customActionWithDuraction(0.001 + duration || 1.0,
                                         action: lambda { |node, time|
        node.zPosition = target_layer if time >= duration
      })
    end

    # Perform a simultaneous move and resize of the target.
    #
    # @param [CGPoint] target_pos The target position to move to.
    #   The same range as for +#do_move+ applies.
    # @param [CGSize] target_size The target size to resize to.
    #   The same range as for +#do_resize+ applies.
    # @param [Double] duration The animation duration in seconds.
    # @return [SKAction] A matching +SKAction+
    def do_move_resize( target_pos, target_size, duration )
      # movement with simultaneous resizing requires to
      # calculate the movement position using the final size.
      final_size = calculate_node_size(target_size,
                                       node.size.width / node.size.height)

      final_pos = calculate_node_position(target_pos, final_size)

      SKAction.group([
        SKAction.moveTo(final_pos, duration: duration || 1.0),
        do_resize(target_size, duration)
      ])
    end
  end
end

