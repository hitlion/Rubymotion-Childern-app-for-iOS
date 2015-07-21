class StoryEditorScreen < StoryPlayerScreen
  include Babbo::AudioRecorder
  include Babbo::MediaChooser

  attr_accessor :story, :scene, :screen

  def on_load
    @object_title = UIBarButtonItem.alloc.initWithTitle( '', style: UIBarButtonItemStylePlain, target: self, action: :dummy )
    @pulse_animation ||= SKAction.repeatActionForever(
                         SKAction.sequence([
                           SKAction.group([
                            SKAction.scaleTo( 1.05, duration: 0.5 ),
                            SKAction.colorizeWithColor( '#ffeeee'.uicolor, colorBlendFactor: 0.0, duration: 0.5 ),
                           ]),
                           SKAction.group([
                            SKAction.scaleTo( 1.00, duration: 0.5 ),
                            SKAction.colorizeWithColor( '#ffeeee'.uicolor, colorBlendFactor: 1.0, duration: 0.5 )
                           ])
                         ])
                       )

    set_toolbar_items [
      { system_item: :done , action: :close },
      { system_item: :flexible_space },
      { image: 'previous'.uiimage, action: :select_previous },
      { system_item: :fixed_space },
      @object_title,
      { system_item: :fixed_space },
      { image: 'next'.uiimage    , action: :select_next     },
      { system_item: :flexible_space },
    ]

  end

  def will_appear
    super
    navigation_controller.navigationBarHidden  = true
    navigation_controller.toolbar.barTintColor = '#f9bc34'.uicolor
    navigation_controller.toolbar.tintColor    = '#ffffff'.uicolor
    @edit_paths = []
    @active_path = 0
    @active_node = nil
    @active_action = nil
  end

  def on_appear
    StoryPlayerScreen.active_instance = self
    show_scene( @active_scene || ':level[1]:screen[1]' )

    @scene.tap_delegate = self
    change_selection
    self.view.becomeFirstResponder
  end

  def on_disappear
    super
  end

  def change_selection
    if @edit_paths.empty?
      set_toolbar_items @empty_items
      return
    end

    if @active_path >= @edit_paths.size
       @active_path = 0
    elsif @active_path < 0
       @active_path = @edit_paths.size - 1
    end

    mp_d "Active editor path: '#{@edit_paths[@active_path]}'"

    unless @active_node.nil?
      @active_node.removeActionForKey( 'pulse' )
      @active_node.alpha = 1.0
      @active_node.colorBlendFactor = 0.0
      @active_node.zPosition = 9988.0
      @active_node = nil
    end
    @active_object = nil

    object = nil
    @scene.enumerateChildNodesWithName( '//*', usingBlock: lambda { |node,_|
      if node.name == @edit_paths[@active_path]
        object = node
        break
      end
    })

    if object.nil?
      mp_d "No scene-object for #{@edit_paths[@active_path]}!"
      set_toolbar_items @empty_items
      return
    end

    object.hidden    = false
    object.alpha     = 1.0
    object.zPosition = 9999.0
    object.runAction( @pulse_animation, withKey: 'pulse' )

    @active_node   = object
    @active_object = @story.object_for_path( @active_node.name )

    @object_title.title = @active_object.name
    show_menu_for_object_active_object
  end

  def dummy
  end

  def show_scene( path, transition=false )
    unless @scene_view.nil?
      @scene_view.removeFromSuperview
      @scene_view.scene.removeAllChildren
    end

    # prepare the new scene
    @screen = @story.object_for_path( path )
    @scene  = @story.create_scene( path, true )

    @scene_view = SKView.alloc.initWithFrame( self.view.bounds )
    @scene_view.presentScene( @scene )
    self.view.addSubview( @scene_view )

    @scene.enumerateChildNodesWithName( '//*', usingBlock: lambda { |node,_|
      if node.is_a? SKSpriteNode and 
         node.userData != nil    and
         node.userData[:player].is_a? AVAudioPlayer
        # audio node
        object = @story.object_for_path( node.name )
        if object and object.modifiable
          node.hidden    = false
        end
      end
    })

    path_filter = @scene.name.gsub( /(\[|\])/ ) { |m| "\\#{m}" }
    @edit_paths  = @story.modifiable_paths.select { |p| p =~ /^#{path_filter}/ }

    @active_object = nil
    @active_node   = nil
    @active_path   = 0
    @active_scene  = path
    change_selection
  end

  def select_next
    @active_path += 1
    change_selection
  end

  def select_previous
    @active_path -= 1
    change_selection
  end

  def record_audio
    #@scene.show_record_controls
    @active_action = :record_audio
    present_audio_recorder( @story.path_for_new_resource_of_type( :audio ) )
  end

  def audio_available( path )
    @active_object.content = @story.relative_path_for_resource( path )
    mp_d "Updated node content to: #{@active_object.content}"

    @active_action = nil if @active_action == :record_audio
  end

  def audio_canceled
    @active_action = nil if @active_action == :record_audio
  end

  def record_movie
    @active_action = :take_video
  end

  def take_picture
    @active_action = :take_picture
    present_photo_chooser
  end

  def photo_chooser_popup_anchor
    @object_title
  end

  def photo_available( image )
    if @active_action == :take_picture
      path = @story.path_for_new_resource_of_type( :picture )

      UIImagePNGRepresentation( image ).writeToFile( path, atomically: true )

      @active_node.texture = SKTexture.textureWithImage( image )
      @active_object.content = @story.relative_path_for_resource( path )

      mp_l "Update object content to: #{@active_object.content}"
      @active_action = nil
    end
  end

  def photo_canceled
      @active_action = nil if @active_action == :take_picture
  end

  def move_object
    @active_action = :move
    @dialog = UIAlertView.alloc.initWithTitle( 'Objekt bewegen',
                                    message: 'Tippen Sie auf die neue Zielposition.',
                                    delegate: nil,
                                   cancelButtonTitle: 'OK',
                                   otherButtonTitles: nil)
    @dialog.show
  end

  def canBecomeFirstResponder
    true
  end

  def canPerformAction( action, withSender: sender )
    case action.to_sym
      when :take_video, :take_picture, :record_audio, :move_object
        true
      else
        false
    end
  end

  def menu_for_object_type( type )
    case type
      when :audio
        @audio_items ||= [
          UIMenuItem.alloc.initWithTitle( 'Ändern', action: :record_audio ),
          UIMenuItem.alloc.initWithTitle( 'Bewegen', action: :move_object )
        ]
      when :video
        @video_items ||= [
          UIMenuItem.alloc.initWithTitle( 'Ändern', action: :take_video ),
          UIMenuItem.alloc.initWithTitle( 'Bewegen', action: :move_object )
        ]
      when :picture
        @image_items ||= [
          UIMenuItem.alloc.initWithTitle( 'Ändern', action: :take_picture ),
          UIMenuItem.alloc.initWithTitle( 'Bewegen', action: :move_object )
        ]
      else
        []
    end
  end

  def show_menu_for_object_active_object( force_location=nil )

    if force_location.nil?
      view_loc = @scene.convertPointToView( @active_node.position )
    else
      view_loc = @scene.convertPointToView( force_location )
    end

    # FIXME: iOS9 Beta 3 bug.. see: https://forums.developer.apple.com/message/17837#17837
    if UIDevice.currentDevice.systemVersion[/^9.0/]
      mp_e "BUG: Applying iOS9 location correction for [https://forums.developer.apple.com/message/17837#17837]"
      view_loc = CGPointMake( view_loc.x, view_loc.y + @scene_view.bounds.size.height )
    end

    self.view.becomeFirstResponder

    menu = UIMenuController.sharedMenuController
    menu.menuItems = menu_for_object_type( @active_object.type )
    menu.setTargetRect( [ [ view_loc.x, view_loc.y ], [ 1, 1 ] ], inView: self.view )
    menu.setMenuVisible( true, animated: true )
  end

  def scene_tapped_at_location( scene_loc, with_object: object )
    if @active_action == :move and ! @active_node.nil?
      @active_node.position = scene_loc
      @active_object.position = object_pos_from_scene_loc( scene_loc )
      @active_action = nil
    else
      #touch_loc = @scene.convertPointToView( scene_loc )
      if @edit_paths.include? object
        @active_path = @edit_paths.index( object )
        change_selection
      end
    end
  end

  def object_pos_from_scene_loc( scene_loc )
    # Babbo-SMIL uses the top-left as anchor point while SKScene uses
    # bottom-left, keep that in mind while doing the calculations..
    CGPointMake( ( scene_loc.x - @active_node.size.width / 2.0 ) / @scene.size.width,
                 ( scene.size.height - ( scene_loc.y + @active_node.size.height / 2.0 ) ) / @scene.size.height )
  end
end

