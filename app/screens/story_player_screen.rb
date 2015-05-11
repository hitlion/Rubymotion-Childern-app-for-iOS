class StoryPlayerScreen < PM::Screen
  attr_accessor :story, :scene, :screen

  def on_appear
    show_scene( ':level[1]:screen[1]' )
  end

  def will_dismiss
    # free up the resounces allocated by SpriteKit
    @scene_view = nil
  end

  def show_scene( path, transition=false )
    scene_view = SKView.alloc.initWithFrame( self.view.bounds )

    @screen = @story.object_for_path( path )
    @scene  = @story.create_scene( path )

    if @scene_view.nil?
      # first SKView, no transition required
      @scene_view = scene_view
      @scene_view.presentScene( @scene )
      self.view.addSubview( @scene_view )

      @screen.emit( 'at_load', @story ) if @screen.is_a? Babbo::Screen
    else
      # transition between different scenes
      # Remove the SKView to free up resources (which SpriteKit woundln't do!)
      # and create a fresh SKView to transition to.

      scene_view.presentScene( @scene )
      scene_view.alpha = 0.0

      self.view.addSubview( scene_view )

      @screen.emit( 'at_load', @story ) if @screen.is_a? Babbo::Screen
      UIView.animateWithDuration( 0.75, animations: lambda {
          scene_view.alpha  = 1.0
          @scene_view.alpha = 0.0
        },
                                     completion: lambda { |_|
          @scene_view.removeFromSuperview 
          @scene_view.scene.removeAllChildren
          @scene_view = nil

          @scene_view = scene_view
        } )
    end
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

