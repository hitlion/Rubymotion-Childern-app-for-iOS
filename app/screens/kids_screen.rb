class KidsScreen < PM::Screen

  attr_accessor :story_list

  def will_appear
    @player = SKView.alloc.initWithFrame(view.bounds)
    rmq(view).append(@player)
    scene = KidsScene.alloc.initWithSize(view.size)
    scene.story_list = @story_list
    @player.presentScene(scene)
  end

  def will_disappear
    @player.presentScene(nil)
    rmq(@player).remove
    @player = nil
  end
end
