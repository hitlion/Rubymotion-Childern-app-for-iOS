module Scene
  class VideoNode < SKVideoNode
    include Scene::NodeHelpersMixin

    attr_reader :av_player

    # Create a new VideoNode bound to +story_object+
    #
    # @param [StoryBundle] bundle The {StoryBundle} containing +story_object+.
    # @param [Scene::Object] story_object The object definition.
    def initialize( bundle, story_object )
      # pre-setup, fetch the video asset and extract it's size
      asset_url  = bundle.asset_path(story_object.content).to_file_url
      asset      = load_video_asset(asset_url)
      video_size = fetch_video_size(asset)

      av_item   = AVPlayerItem.playerItemWithAsset(asset)
      av_player = AVPlayer.playerWithPlayerItem(av_item)

      initWithAVPlayer(av_player).tap do
        self.name      = story_object.path
        self.size      = calculate_node_size(story_object.size,
                                             video_size.width / video_size.height,
                                             story_object.resize)
        self.position  = calculate_node_position(story_object.position,
                                                 self.size)
        self.zPosition = story_object.layer
        self.alpha     = 1.0 - story_object.transparency

        # Setup playback notifications (why can't this be done via delegation!?)
        @av_player     = av_player
      end
    end

    # @private
    def to_s
      format('<VideoNode \'%s\' position=<x=%.2f, y=%.2f, z=%.2f>, size=<w=%.2f, h=%.2f>>',
             self.name, self.position.x, self.position.y, self.zPosition,
             self.size.width, self.size.height)
    end

    # Start the video playback.
    def play
      super
      register_notifications
    end

    # @private
    # callback on video done, triggers :at_end
    def playback_done( *args )
      NSNotificationCenter.defaultCenter.removeObserver(self)
      JavaScript::Runtime.send_event(self.name, :at_end)
    end


    private

    # Load the video at +asset_url+ and return a matching +AVAsset+.
    # If the video ist not available a placeholder will be returned instead.
    #
    # @param [String] asset_url The file system URL to the asset.
    # @return [AVAsset] The initialized asset instance.
    def load_video_asset( asset_url )
      unless File.exists? asset_url.fileSystemRepresentation
        mp "Video asset '#{asset_url.fileSystemRepresentation}' is missing.",
           force_color: :cyan

        asset_url = Dir.resource('placeholder/file_warning.m4v').to_file_url
      end

      AVURLAsset.URLAssetWithURL(asset_url, options: nil)
    end

    # Fetch the frame size of the first video track inside +asset+.
    # 
    # @param [String] asset The video asset to extract the size from.
    # @return [CGSize] The videos frame size (naturalSize) or [1.0,1.0]
    #   in case of errors.
    def fetch_video_size( asset )
      media_type = AVMediaTypeVideo
      track_info = asset.tracksWithMediaType(media_type).first

      if track_info.nil?
        mp 'Video asset contains no video tracks!', force_color: :red
        CGSize.new(1.0, 1.0)
      else
        track_info.naturalSize
      end
    end

    # Register for playback notifications with the global NotificationCenter
    def register_notifications
        notify = NSNotificationCenter.defaultCenter
        notify.removeObserver(self)
        notify.addObserver(self,
                           selector: 'playback_done',
                           name: AVPlayerItemDidPlayToEndTimeNotification,
                           object: @av_player.currentItem)

        notify.addObserver(self,
                           selector: 'playback_done',
                           name: AVPlayerItemFailedToPlayToEndTimeNotification,
                           object: @av_player.currentItem)
    end
  end
end

