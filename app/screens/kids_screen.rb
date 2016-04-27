class KidsScreen < PM::Screen

  include OrientationModule

  def will_appear
    @player = SKView.alloc.initWithFrame(view.bounds)
    rmq(view).append(@player)


    unless @player.scene
      if(true)
        tutorial = KidsSceneTutorial.alloc.initWithSize(view.size)
        @player.presentScene(tutorial)
      else
        scene = KidsScene.alloc.initWithSize(view.size)
        @player.presentScene(scene)
      end
    end

  end

  def will_disappear
    @player.presentScene(nil)
    rmq(@player).remove
    @player = nil
  end

end
