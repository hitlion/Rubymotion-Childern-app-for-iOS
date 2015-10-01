module Scene
  class GIFVideoNode < SKSpriteNode
    include Scene::NodeHelpersMixin

    attr_accessor :av_player

    # @private
    # dummy AVPlayer stub used for duck-typing
    # a Scene::VideoNode
    class AVDummy
      attr_accessor :rate, :currentTime

      def seekToTime(_); end
      def pause; end
      def play; end
    end

    # Create a new GIFVideoNode bound to +story_object+
    #
    # @param [StoryBundle] bundle The {StoryBundle} containing +story_object+.
    # @param [Scene::Object] story_object The object definition.
    def initialize( bundle, story_object )
      initWithColor(rmq.color.clear, size: [0, 0]).tap do
        series = UIImage.imagesFromAnimatedGifData(bundle.asset_data(story_object.content))

        if series.nil?
          lp "Could not extract GIF images for node '#{story_object.path}'",
             force_color: :yellow
          @animation = nil
        else
          image = UIImage.imageWithCGImage(series.first.first)
          @animation = animation_series(series)
        end

        if image.nil?
          image = rmq.image.resource('placeholder/file_warning')
          lp "Missing picture for node '#{story_object.path}'",
             force_color: :yellow
        end

        self.texture  = SKTexture.textureWithImage(image)
        self.size     = calculate_node_size(story_object.size,
                                            image.size.width / image.size.height,
                                            story_object.resize)
        self.position = calculate_node_position(story_object.position,
                                                self.size)
        self.zPosition = story_object.layer
        self.alpha     = 1.0001 - story_object.transparency
        self.name      = story_object.path
        @av_player     = AVDummy.new
      end
    end

    # @private
    def to_s
      format('<GIFVideoNode \'%s\' position=<x=%.2f, y=%.2f, z=%.2f>, size=<w=%.2f, h=%.2f>>',
             self.name, self.position.x, self.position.y, self.zPosition,
             self.size.width, self.size.height)
    end

    # Start the video playback.
    def play
      return if @animation.nil?

      av_player.rate = 1.0
      av_player.currentTime = 1

      animation = actionForKey('playback') || runAction(@animation, withKey:'playback')
      animation.speed = 1.0 unless animation.nil?
    end

    def pause
      return if @animation.nil?

      av_player.rate = 0.0
      av_player.currentTime = 1

      animation = actionForKey('playback')
      animation.speed = 0.0 unless animation.nil?
    end

    def stop
      return if @animation.nil?

      av_player.rate = 0.0
      av_player.currentTime = KCMTimeZero

      removeActionForKey('playback')
    end

    # @private
    # callback on video done, triggers :at_end
    def playback_done
      stop
      JavaScript::Runtime.send_event(self.name, :at_end)
    end

    private

    # @private
    # Create texture animation using the images and delays specified in series.
    #
    # @param [Array<Array<CGImage, Float>>] series An +Array+ of CGImage /
    #   delay pairs.
    # @return [SKAction] The animation action or nil if errors occured.
    def animation_series(series)
      # SpriteKit doesn't suppor variable framerate animations, get an avaerage delay
      frame_delay = 1.0
      unless series.count <= 1
        frame_delay = series.map { |m| m[1] }.inject(:+) / series.count
      end

      textures = series.map { |m| SKTexture.textureWithCGImage(m[0]) }
      animation = SKAction.animateWithTextures(textures, timePerFrame: frame_delay )

      # couple the animation with a completion callback
      callback = SKAction.runBlock(-> { self.playback_done })
      SKAction.sequence([animation, callback])
    end
  end
end

