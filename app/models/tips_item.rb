class TipsItem

  attr_reader :image, :header, :text

  def initWithImage(image, header: header, text: text)
    @image = image
    @text = text
    @header = header
    self
  end
end