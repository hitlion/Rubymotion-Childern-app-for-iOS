class KidsScreen < PM::Screen

  include OrientationModule

  def will_appear
    NSNotificationCenter.defaultCenter.removeObserver(self)

    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector: 'tutorial_closed',
                                                   name: 'TutorialClosed',
                                                   object: nil)

    @player = SKView.alloc.initWithFrame(view.bounds)
    rmq(view).append(@player)

    @player.presentScene(get_scene)
  end

  def will_disappear
    @player.presentScene(nil)
    rmq(@player).remove
    @player = nil
  end

  def tutorial_closed
    @player.presentScene(nil)
    @player.presentScene(KidsScene.alloc.initWithSize(view.size))
  end

  def get_scene
    return nil unless @player

    unless @player.scene
      if(NSUserDefaults.standardUserDefaults.boolForKey('de.tuluh_tec.babbo_voco.hide_tutorial_ever') ||
          NSUserDefaults.standardUserDefaults.boolForKey('de.tuluh_tec.babbo_voco.show_tutorial') == false)
        scene = KidsScene.alloc.initWithSize(view.size)
      else
        scene = KidsSceneTutorial.alloc.initWithSize(view.size)
      end
    end

    return scene
  end

end
