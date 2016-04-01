class ShopProduct

  attr_reader :set_name, :price, :rating, :thumbnail_path, :thumbnail, :description, :screenshots,
              :screenshot_paths, :identifier, :valid

  def initialize( product )
    @valid = false
    @indentifier = product.productIdentifier
    @set_name    = product.localizedTitle
    @price       = product.price
    @description = product.localizedDescription

    @rating            = ServerBackend.get.get_rating_for_identifier(@indentifier)
    @thumbnail_path         = ServerBackend.get.get_thumbnail_for_identifier(@indentifier)
    @screenshot_paths  = ServerBackend.get.get_screenshots_for_identifier(@indentifier)

    @screenshots = nil
    @thumbnail = nil

    unless(@identifier.nil? || @name.nil? || @price.nil? || @description.nil? || @rating.nil? || @thumbnail.nil? || @screenshot_paths.nil?)
      @valid = true
    end

  end

  def valid?
    return @valid
  end

  def thumbnail
    @thumbnail ||=  UIImage.imageWithData(NSData.dataWithContentsOfURL(@thumbnail_path.to_url))
    return @thumbnail
  end

  def screenshots
   if(@screenshots.nil?)
     @screenshots = []

     @screenshot_paths.each do |path|
       @screenshots << UIImage.imageWithData(NSData.dataWithContentsOfURL(path.to_url))
     end
   end

   return @screenshots
  end

  def clean_chache
    @thumbnail = nil
    @screenshots = nil
  end

end