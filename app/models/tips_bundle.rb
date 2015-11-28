class TipsBundle
  attr_accessor :bundle

  def init
    @bundle = []

    testString = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
    tipA = TipsItem.alloc.initWithImage(UIImage.imageNamed("Testbild.png"), header:"Test 1", text: testString)
    tipB = TipsItem.alloc.initWithImage(UIImage.imageNamed("Testbild.png"), header:"Test 2", text: "asfdafafafasfasfasfafasfasfasf")
    tipC = TipsItem.alloc.initWithImage(UIImage.imageNamed("Testbild.png"), header:"Test 3", text: "afakjhasfasfasfasfasfasfasffbaikfakfal")

    @bundle = [tipA, tipB, tipC]

    @bundle
  end
end