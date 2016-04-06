class TTUtil

  # Get the standard font size in depency of the device
  # @param size define the size with one of the following tags
  # :small, :medium, :large, :xl
  def self.get_font_size(size)
    if(device.ipad?)
      return FONT_SIZE_IPAD_XS        if size == :xs
      return FONT_SIZE_IPAD_SMALL     if size == :small
      return FONT_SIZE_IPAD_MEDIUM    if size == :medium
      return FONT_SIZE_IPAD_LARGE     if size == :large
      return FONT_SIZE_IPAD_XL        if size == :xl
      return FONT_SIZE_IPAD_XXL       if size == :xxl
    else
      return FONT_SIZE_IPHONE_XS      if size == :xs
      return FONT_SIZE_IPHONE_SMALL   if size == :small
      return FONT_SIZE_IPHONE_MEDIUM  if size == :medium
      return FONT_SIZE_IPHONE_LARGE   if size == :large
      return FONT_SIZE_IPHONE_XL      if size == :xl
      return FONT_SIZE_IPHONE_XXL     if size == :xxl
    end

    return 0
  end

  # Get the standard font with the given type
  # @param type The following types are defined
  # :bold, :regular
  def self.get_font_standard(type)
    return FONT_STANDARD_BOLD if type == :bold
    return FONT_STANDARD_REGULAR
  end

  def self.unzip_file(file_url, toDestination: destination, withName: name)
    Dispatch::Queue.concurrent.sync do
      NSLog("Entpacke Daten von %@ ...", file_url)
      data = NSData.dataWithContentsOfURL(file_url)

      return if data.nil?

      file_name = file_url.lastPathComponent
      file_path = "#{NSTemporaryDirectory()}#{file_name}"

      data.writeToFile(file_path, atomically: true)
      data_path = destination.stringByAppendingPathComponent(name)

      SSZipArchive.unzipFileAtPath(file_path, toDestination: data_path)

      NSLog('Daten entpackt!')
    end
  end

end