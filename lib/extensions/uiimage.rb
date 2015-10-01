# +UIImage+ extension to support loading of animated GIFs.
class UIImage
  class << self
    def imagesFromAnimatedGifFile( path )
      UIImage.imagesFromAnimatedGifData(NSData.dataWithContentsOfFile(path))
    end

    # Return an +Array+ containing the images and timing
    # information retrieved by reading a +NSData+ object.
    #
    # @param [NSData] data The raw image data
    # @return [Array<Array<UIImage, Double>>] or +nil+ if data could not
    #   be parsed or is not a valid GIF image series.
    def imagesFromAnimatedGifData( data )
      return nil if data.nil?

      # 1. setup a CGImageSource and extract the image count
      source = CGImageSourceCreateWithData(data, nil)
      count = CGImageSourceGetCount(source) unless source.nil?

      return nil if source.nil?

      # 2. extract each image and check it's metadata for the required
      #    animation delay.
      images = []
      lp "--> gif has #{count} images"
      (0...count).each do |index|
        image = CGImageSourceCreateImageAtIndex(source, index, nil)
        delay = copy_animation_delay(source, index)

        images << [image, delay] unless image.nil?
      end
      images
    end

    private

    # Extract the expected delay time for a given image.
    #
    # @param [CGImageSourceRef] source The source holding all images.
    # @param [Fixnum] index The image index inside of the source.
    # @return [Float] The expected delay time for this image.
    #   If no delay time could be extracted this method will return 0.0.
    def copy_animation_delay( source, index )
      delay = 0.0
      props = CGImageSourceCopyPropertiesAtIndex(source, index, nil)

      unless props.nil?
        gif_props = props[KCGImagePropertyGIFDictionary]
        unless gif_props.nil?
          # extract the delay using the following fallback order:
          # -> GIF unclamped delay time
          # --> GIF delay time
          # ---> fixed 0.0 second delay
          gif_delay = gif_props.fetch(KCGImagePropertyGIFUnclampedDelayTime,
                                      gif_props.fetch(KCGImagePropertyGIFDelayTime,
                                                      NSNumber.numberWithDouble(0.0)))
          delay = gif_delay.doubleValue
        end
      end
      delay
    end
  end
end

