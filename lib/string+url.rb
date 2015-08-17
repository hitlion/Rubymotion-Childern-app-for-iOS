class String
  # Return a new +NSURL+ containing the receiver # converted to a file URL.
  # @return [NSURL] The file URL matching the receiver
  def to_file_url
    NSURL.fileURLWithPath(self)
  end

  # Return a new +NSURL+ containing the receiver converted to a URL.
  # @return [NSURL] Ther URL matching the receiver.
  def to_url
    NSURL.URLWithString(self)
  end
end

