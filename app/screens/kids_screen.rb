class KidsScreen < PM::Screen

  attr_accessor :story_list

  def will_appear
    player = SKView.alloc.initWithFrame(self.view.bounds)
    rmq(self.view).append(player)
    scene = KidsScene.alloc.initWithSize(self.view.size)
    scene.story_list = @story_list
    player.presentScene(scene)
  end

end
