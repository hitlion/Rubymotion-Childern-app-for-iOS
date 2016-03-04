module Scene
  class AudioNode < SKSpriteNode
    include Scene::NodeHelpersMixin

    attr_reader :av_player

    # Create a new AudioNode bound to +story_object+
    #
    # @param [StoryBundle] bundle The {StoryBundle} containing +story_object+.
    # @param [Scene::Object] story_object The object definition.
    def self.create( bundle, story_object )
      AudioNode.alloc.initWithColor(rmq.color.clear, size: [0, 0]).tap do |node|
        node.instance_eval do
          image = rmq.image.resource('placeholder/file_music')
          audio = bundle.asset_data(story_object.content)
          if audio.nil?
            image = rmq.image.resource('placeholder/file_warning')
            lp "Missing audio for node '#{story_object.path}'",
               force_color: :cyan
            @av_player = nil
          else
            error = Pointer.new(:object)

            audio_url = bundle.asset_path(story_object.content).to_file_url
            @av_player = AVAudioPlayer.alloc.initWithContentsOfURL(audio_url, error: error)

            if @av_player.nil?
              lp "Error loading audio for node '#{story_object.path}': #{error[0].localizedDescription}",
                 force_color: :cyan
            end
          end

          self.name      = story_object.path
          self.texture   = SKTexture.textureWithImage(image)
          self.size      = image.size
          self.position  = calculate_node_position(story_object.position,
                                                  self.size)
          self.zPosition = story_object.layer
          self.alpha     = 1.00001 - story_object.transparency
          self.hidden    = true

          unless @av_player.nil?
            @av_player.delegate = self
          end
        end
      end
    end

    # @private
    def to_s
      format('<AudioNode \'%s\' position=<x=%.2f, y=%.2f, z=%.2f>, size=<w=%.2f, h=%.2f>>',
             self.name, self.position.x, self.position.y, self.zPosition,
             self.size.width, self.size.height)
    end

    # Start the audio playback.
    def play
      unless @av_player.nil?
        @av_player.currentTime = 0.0
        @av_player.play
      end
    end

    # Pause the audio playback.
    def pause
      @av_player.pause unless @av_player.nil?
    end

    # Stop the audio playback
    def stop
      @av_player.stop unless @av_player.nil?
    end

    # Restart the playback after {#pause} was called.
    def restart
      @av_player.play unless @av_player.nil?
    end

    # Query the player status.
    #
    # @return [String] On of 'play', 'pause', 'stop'
    def status
      if @av_player.nil?
        'stop'
      else
        if @av_player.playing
          'play'
        elsif @av_player.currentTime > 0.0
          'pause'
        else
          'stop'
        end
      end
    end

    ## AVAudioPlayerDelegate

    # @private
    # Called when playback finishes, triggers :at_end
    def audioPlayerDidFinishPlaying( _, successfully: _ )
      JavaScript::Runtime.send_event(self.name, :at_end)
    end

    # @private
    # Called when playback fails, also triggers :at_end
    def audioPlayerDecodeErrorDidOccur( _, error: _ )
      JavaScript::Runtime.send_event(self.name, :at_end)
    end
  end
end

