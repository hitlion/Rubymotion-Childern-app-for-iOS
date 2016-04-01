class StoryPlayerScreen < PM::Screen
  title 'Babbo Voco'
  stylesheet StoryPlayerStylesheet

  attr_accessor :story_bundle

  include OrientationModule

  class << self
    attr_accessor :instance

    def get( bundle )
      StoryPlayerScreen.instance ||= StoryPlayerScreen.new(nav_bar: false)
      StoryPlayerScreen.instance.story_bundle = bundle unless bundle.nil?
      StoryPlayerScreen.instance
    end

    def dispose!
      StoryPlayerScreen.instance = nil
    end
  end

  def on_load
    rmq(self.view).apply_style(:root)

    @player = rmq.unshift!(ScenePlayer, :scene_player)

    if app.development? || app.ad_hoc_release?
      @logger = rmq(self.view).append(StoryLoggerView).tag(:logger).get
      rmq(@player).append(@logger) unless @logger.nil?
    end
  end

  def will_appear
    scene  = SceneFactory.create_scene(@story_bundle, ':level[1]:screen[1]', :player)

    @logger.clear! unless @logger.nil?
    @player.presentScene(nil)
    @player.presentScene(scene)

    NSNotificationCenter.defaultCenter.removeObserver(self)
    NSNotificationCenter.defaultCenter.addObserver(self,
                                                  selector: 'on_screen_event:',
                                                  name: 'screen_exit_event',
                                                  object: nil)

    JavaScript::Runtime.prepare_for(@story_bundle, scene)
  end

  def on_appear
    JavaScript::Runtime.send_event(':body', :at_load, async: false )
    JavaScript::Runtime.send_event(@player.scene.name, :at_load)
  end

  def will_disappear
    NSNotificationCenter.defaultCenter.removeObserver(self)

    unless @player.scene.nil?
      @player.scene.removeAllChildren
      @player.scene.removeAllActions
      @player.scene.removeFromParent
    end

    @logger.clear! unless @logger.nil?
    @player.presentScene(nil)

    @story_bundle = nil

    JavaScript::Runtime.tear_down
  end

  def on_screen_event( notification )
    info = Hash.symbolicate(notification.userInfo || {})
    Dispatch::Queue.main.async do
      if info.has_key? :exit_to
        show_scene(info[:exit_to])
      else
        # cancel the global timer object
        JavaScript::Global.shutdown_timer
        close
      end
    end
  end

  def show_scene( target )
    # transition_image = create_transition_image

    unless @player.scene.nil?
      @player.scene.removeAllChildren
      @player.scene.removeAllActions
      @player.scene.removeFromParent
    end
    @player.presentScene(nil)

    scene  = SceneFactory.create_scene(@story_bundle, target, :player)

    if scene.nil?
      # FIXME
      lp "bailouto"
      return
    end
    # scene.addChild(transition_image)

    @logger.clear!

    @player.presentScene(scene)

    JavaScript::Runtime.get.scene_root = scene
    JavaScript::Runtime.send_event(@player.scene.name, :at_load)
  end

  private

  # Create a single sprite node containing an image of
  # the current scene for use in fading / transitions etc.
  #
  # @return [SKSpriteNode]
  def create_transition_image
    texture = @player.textureFromNode(@player.scene)
    SKSpriteNode.spriteNodeWithTexture(texture).tap do |node|
      node.size      = @player.scene.size
      node.position  = CGPoint.new(node.size.width / 2.0, node.size.height / 2.0)
      node.zPosition = 10_000
      node.runAction(SKAction.sequence([
        SKAction.fadeOutWithDuration(0.75),
        SKAction.removeFromParent,
        SKAction.runBlock(-> {node.texture = nil})
      ]))
    end
  end
end

