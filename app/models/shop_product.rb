class ShopProduct

  attr_reader :set_name, :price, :rating, :thumbnail_path, :thumbnail, :description, :screenshots,
              :screenshot_paths, :productIdentifier, :valid, :installed
  attr_accessor :downloading

  def initialize( product )
    @valid = false
    @productIdentifier = product.productIdentifier
    @set_name    = product.localizedTitle
    @price       = product.price
    @description = product.localizedDescription

    @rating            = ServerBackend.get.get_rating_for_identifier(@productIdentifier)
    @thumbnail_path    = ServerBackend.get.get_thumbnail_for_identifier(@productIdentifier)
    @screenshot_paths  = ServerBackend.get.get_screenshots_for_identifier(@productIdentifier)

    @screenshots = nil
    @thumbnail = nil
    @installed = false
    @downloading = false

    unless(@productIdentifier.nil? && @set_name.nil? && @price.nil? && @description.nil? &&@rating.nil? && @thumbnail_path.nil? && @screenshot_paths.nil?)
      @valid = true
    end
    @installed = false

    StoryBundle.bundles.each do |story|
      if(story.valid?)
        if(story.document.productIdentifier == @productIdentifier)
          @installed = true
        end
      end
    end
    #@installed = !StoryBundle.bundles.select{|story| story.document.productIdentifier == @productIdentifier}.nil?
    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector: 'bundlesChanges:',
                                                   name: 'BabboBundleChanged',
                                                   object: nil)
  end

  # @return [boolean] if the products values are all valid
  def valid?
    return @valid
  end

  # gives and cheas the thumbnail for this product
  # @return [UIImage] An UIImage with the
  def thumbnail
    return nil unless @valid
    #TODO : aktivieren wenn wieder vom Server geladen wird
    #@thumbnail ||=  UIImage.imageWithData(NSData.dataWithContentsOfURL(@thumbnail_path.to_url))
    @thumbnail ||= rmq.image.resource(@thumbnail_path)
    return @thumbnail
  end

  # gives and caches the screenshots for this product
  # @return [Array <UIImage>] an Array of UIImages
  def screenshots
    return nil unless @valid
    if(@screenshots.nil?)
      screenshots = []

      @screenshot_paths.each do |path|
        #TODO : aktivieren wenn wieder vom Server geladen wird
        screenshots << UIImage.imageWithData(NSData.dataWithContentsOfURL(path.to_url))
        #screenshots << rmq.image.resource(path)
      end

      @screenshots = screenshots
    end

    return @screenshots
  end

  # clear the cached thumbnail and screenshots
  def clear_chache
    @thumbnail = nil
    @screenshots = nil
  end

  def not_installed?
    return !@installed
  end

  def bundlesChanges(notification)
    NSLog("Shopbundle updated: %@", self.set_name)

    if notification.userInfo[:changed_bundle].document.productIdentifier == @productIdentifier
      @installed = notification.userInfo[:status] == :added

      NSNotificationCenter.defaultCenter.postNotificationName('ShopBundleChanged',
                                                              object:nil)
    end
  end

end