class StoryPlayerScreen < PM::Screen
  attr_accessor :story, :scene, :screen

  class << self
    attr_accessor :active_instance
  end

  def on_appear
    StoryPlayerScreen.active_instance = self
    show_scene( ':level[1]:screen[1]' )
  end

  def on_disappear
    # free up the resounces allocated by SpriteKit
    @scene_view .removeFromSuperview
    @screen     = nil
    @scene      = nil
    @scene_view = nil

    super
  end

  def show_scene( path, transition=false )
    skdummy = nil
    unless @scene_view.nil?
      if transition
        # render the old scene to a texture..
        texture = @scene_view.textureFromNode( @scene_view.scene )
        # .. and put that on a sprite node..
        skdummy = SKSpriteNode.spriteNodeWithTexture( texture )
        # .. setup that node to fill the scene and be on top of all others
        skdummy.zPosition = 99999.0
        skdummy.size = @scene.size
        skdummy.position = [ @scene.size.width / 2.0, @scene.size.height / 2.0 ]
        # .. then add actions to fade-out and remove the node
        skdummy.runAction( SKAction.sequence( [ SKAction.fadeOutWithDuration( 0.75 ),
                                                SKAction.removeFromParent ] ) )
      end

      # with the mockup of the old scene in-place remove it to free it's
      # resources
      @scene_view.removeFromSuperview
      @scene_view.scene.removeAllChildren
    end

    # prepare the new scene
    @screen = @story.object_for_path( path )
    @scene  = @story.create_scene( path )

    unless skdummy.nil?
      @scene.addChild( skdummy )
    end

    @scene_view = SKView.alloc.initWithFrame( self.view.bounds )
    @scene_view.presentScene( @scene )
    self.view.addSubview( @scene_view )

    @screen.emit( 'at_load', @story ) if @screen.is_a? Babbo::Screen
  end

  # force landscape orientation
  def supportedInterfaceOrientations()
    UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight
  end

  def preferredInterfaceOrientationForPresentation()
    UIInterfaceOrientationLandscapeRight
  end

  def shouldAutorotate()
    true
  end
end

