class StoryPlayerScreen < PM::Screen
  title 'Babbo Voco'
  stylesheet StoryPlayerStylesheet

  attr_accessor :story_bundle

  def on_load
    rmq(self.view).apply_style(:root)

    if app.development? || app.ad_hoc_release?
      @logger = rmq(self.view).append(StoryLoggerView).tag(:logger).get
    end
  end

  def will_appear
    @scene  = SceneFactory.create_scene(@story_bundle, ':level[1]:screen[1]')
    @player = rmq.unshift!(ScenePlayer, :scene_player)
    @player.presentScene(@scene)

    rmq(@player).append(@logger) unless @logger.nil?

    JavaScript::Runtime.prepare_for(@story_bundle, @scene)
  end

  def on_appear
    JavaScript::Runtime.send_event(':body', :at_load, async: false )
    JavaScript::Runtime.send_event(@scene.name, :at_load)
  end

  def on_dismiss
    rmq(@logger).remove
    rmq(@player).remove

    @scene.removeAllChildren unless @scene.nil?

    @story_bundle = nil
    @player = nil
    @scene  = nil

    JavaScript::Runtime.tear_down
  end

  def show_scene( target )
    transition_image = create_transition_image
    rmq(@logger).remove
    rmq(@player).remove

    @scene.removeAllChildren unless @scene.nil?

    @player = nil
    @scene  = nil

    @scene  = SceneFactory.create_scene(@story_bundle, target)

    if @scene.nil?
      # FIXME
      lp "bailouto"
      return
    end
    @scene.addChild(transition_image)

    @player = rmq.unshift!(ScenePlayer, :scene_player)
    @player.presentScene(@scene)

    rmq(@player).append(@logger) unless @logger.nil?

    JavaScript::Runtime.get.scene_root = @scene
    JavaScript::Runtime.send_event(@scene.name, :at_load)
  end

  private

  # Create a single sprite node containing an image of
  # the current scene for use in fading / transitions etc.
  #
  # @return [SKSpriteNode]
  def create_transition_image
    texture = @player.textureFromNode(@scene)
    SKSpriteNode.spriteNodeWithTexture(texture).tap do |node|
      node.size      = @scene.size
      node.position  = CGPoint.new(node.size.width / 2.0, node.size.height / 2.0)
      node.zPosition = 10_000
      node.runAction(SKAction.sequence([
        SKAction.fadeOutWithDuration(0.75),
        SKAction.removeFromParent
      ]))
    end
  end
end

