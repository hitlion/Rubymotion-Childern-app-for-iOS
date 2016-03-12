class TipsBundle
  attr_accessor :bundle

  def init
    @bundle = []

    ServerBackend.get.number_of_tips.times do |index|
      tip = TipsItem.alloc.initWithImage(ServerBackend.get.image_for_tip(index),
                                         header: ServerBackend.get.header_for_tip(index),
                                         text: ServerBackend.get.description_for_tip(index))
      @bundle << tip
    end

    @bundle.shuffle
  end
end