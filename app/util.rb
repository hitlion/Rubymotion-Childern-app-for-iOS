class Util

  # Get the standard font size in depency of the device
  # @param size define the size with one of the following tags
  # :small, :medium, :large, :xl
  def self.get_font_size(size)
    if(device.ipad?)
      return FONT_SIZE_IPAD_SMALL     if size == :small
      return FONT_SIZE_IPAD_MEDIUM    if size == :medium
      return FONT_SIZE_IPAD_LARGE     if size == :large
      return FONT_SIZE_IPAD_XL        if size == :xl
    else
      return FONT_SIZE_IPHONE_SMALL   if size == :small
      return FONT_SIZE_IPHONE_MEDIUM  if size == :medium
      return FONT_SIZE_IPHONE_LARGE   if size == :large
      return FONT_SIZE_IPHONE_XL      if size == :xl
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

end