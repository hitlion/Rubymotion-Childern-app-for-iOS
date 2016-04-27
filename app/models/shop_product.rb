class ShopProduct

  attr_reader :set_name, :price, :rating, :thumbnail_urls, :thumbnail, :description, :screenshots,
              :screenshot_urls, :productIdentifier, :installed, :timestamp
  attr_accessor :downloading, :buying

  def initialize( product )
    @productIdentifier = product.productIdentifier
    @set_name    = product.localizedTitle
    @price       = product.price
    @description = product.localizedDescription
    @installed = false
    @downloading = false
    @buying = false

    StoryBundle.bundles.each do |story|
      @installed = story.document.productIdentifier == @productIdentifier
    end

    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector: 'bundles_changes:',
                                                   name: 'BabboBundleChanged',
                                                   object: nil)
    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector: 'screenshot_urls_received:',
                                                   name: 'BackendScreenshotURLReceived',
                                                   object: nil)
    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector: 'thumbnail_url_received:',
                                                   name: 'BackendThumbnailURLReceived',
                                                   object: nil)
    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector: 'timestamp_received:',
                                                   name: 'BackendDateReceived',
                                                   object: nil)

    BabboBackend.get.request_thumbnail_url_for_identifier(@productIdentifier, sender: self)
    BabboBackend.get.request_screenshots_urls_for_identifier(@productIdentifier, sender: self)
    BabboBackend.get.request_timestamp_for_identifier(@productIdentifier, sender: self)
  end

  # This method return the thumbnail for this shop object,
  # if it is already loaded and cached from the backend.
  # Otherwise this method send a request for the path (url) to the thumbnail.
  # If the url is already received load the image. In both cases return nil.
  # @return [UIImage] Thumbnail for this Shop Object or +nil+ if loading and cache isnt done
  def thumbnail
    unless @thumbnail_url
      BabboBackend.get.request_thumbnail_url_for_identifier(@productIdentifier, sender:self)
      return nil
    end

    unless @thumbnail
      load_thumbnail(@thumbnail_url)
      return nil
    end

    return @thumbnail
  end

  # This method return the screenshots for this shop object,
  # if it is already loaded and cached from the backend.
  # Otherwise this method send a request for the paths (URLs) to the screenshots.
  # If the URLs are already received load the images. In both cases return nil.
  # @return [Array <UIImage>] an Array of UIImages or +nil+ if if loading and cache is not done
  def screenshots
    if(@screenshots.nil?)
      unless @screenshot_urls
        BabboBackend.get.request_screenshots_urls_for_identifier(@productIdentifier, sender:self)
        return nil
      else
        load_screenshots(@screenshot_urls)
        return nil
      end
    end

    return @screenshots
  end

  # clear the cached thumbnail and screenshots
  def clear_chache
    #@thumbnail = nil
    #@screenshots = nil
  end

  def not_installed?
    return !@installed
  end


  private

  # call this method after the receive of a bundles has changed notification
  # update the installed attribute if the notification contains the identifier of
  # this shop object
  def bundles_changes(notification)
    if notification.userInfo[:changed_bundle].document.productIdentifier == @productIdentifier
      @installed = notification.userInfo[:status] == :added
      bundle_information_updated
    end
  end

  # Call this after update a value of this shop product.
  # The receiver should be implemented in the shop view.
  # After receiving this notification the view should request the bundle information again
  # and update the view with the new information
  def bundle_information_updated
    NSNotificationCenter.defaultCenter.postNotificationName('ShopBundleInformationUpdated',
                                                            object:nil,
                                                            userInfo: {
                                                                identifier: @productIdentifier
                                                            })
  end

  # Receiver method for the thumbnail callback.
  # Saves the given path to the thumbnail. Request loading from the path.
  def thumbnail_url_received(notification)
    return unless notification.userInfo[:sender] == self
    @thumbnail_url = notification.userInfo[:url].to_url
    bundle_information_updated
  end

  # Receiver method for the screenshots callback
  def screenshot_urls_received(notification)
    return unless notification.userInfo[:sender] == self
    urls = notification.userInfo[:url]
    @screenshot_urls = []
    urls.each do |url|
      @screenshot_urls << url.to_url
    end
    bundle_information_updated
  end

  # Receiver method for the timestamp callback
  def timestamp_received(notification)
    return unless notification.userInfo[:sender] == self
    @timestamp = notification.userInfo[:date]
  end


  # Load the thumbnail for this shop story
  # @param [String] url The URL to the thumbnail for this shop object
  # @return [Boolean] Return +true+ if the thumbnail was loading successful or false if errors occur
  def load_thumbnail(url)
    return false if url.nil? || url == ""
    Dispatch::Queue.concurrent.async do
      @thumbnail = UIImage.imageWithData(NSData.dataWithContentsOfURL(url))
      bundle_information_updated
    end

  end

  # Load the screenshots for this shop story
  # @param [String] url The URL to the thumbnail for this shop object
  # @return [Boolean] Return +true+ if the thumbnail was loading successful or false if errors occur
  def load_screenshots(urls)
    return false if urls.nil? || urls.empty?
    @screenshots = []

    Dispatch::Queue.concurrent.async do
      urls.each  do |url|
        @screenshots << UIImage.imageWithData(NSData.dataWithContentsOfURL(url))
      end
      bundle_information_updated
    end
  end

end