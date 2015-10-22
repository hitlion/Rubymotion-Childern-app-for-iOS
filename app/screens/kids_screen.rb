class KidsScreen < PM::Screen

  attr_accessor :story_list

  def will_appear
    player = SKView.alloc.initWithFrame(self.view.bounds)
    rmq(self.view).append(player)
    scene =KidsScene.alloc.initWithSize(self.view.size)
    player.presentScene(scene)
  end

  def open_parent_menu
    open StoryListScreen.new(nav_bar: true , nav_controller: AutoRotatingNavigationController)
  end

end
