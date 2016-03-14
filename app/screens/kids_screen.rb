class KidsScreen < PM::Screen

  def will_appear
    @player = SKView.alloc.initWithFrame(view.bounds)
    rmq(view).append(@player)
    scene = KidsScene.alloc.initWithSize(view.size)
    @player.presentScene(scene)
  end

  def will_disappear
    @player.presentScene(nil)
    rmq(@player).remove
    @player = nil
  end

  def should_rotate(orientation)
    if orientation == UIInterfaceOrientationLandscape
      true
    else
      false
    end
  end

end
