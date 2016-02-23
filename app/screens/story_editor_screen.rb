class StoryEditorScreen < PM::Screen
  title 'Babbo Voco'
  stylesheet StoryEditorStylesheet

  include MediaChooser
  include AudioRecorder

  attr_accessor :story_bundle
  attr_reader :level, :screen, :editable, :player

  class << self
    attr_accessor :instance

    def get( bundle, edit_existing=false )
      StoryEditorScreen.instance ||= StoryEditorScreen.new(nav_bar: false)
      unless bundle.nil?
        if edit_existing
          # modify the existing bundle object
          StoryEditorScreen.instance.story_bundle = bundle
        else
          # create a copy and work on that
          bundle.instance_eval { @paths = nil }
          StoryEditorScreen.instance.story_bundle = Marshal.load(Marshal.dump(bundle))
        end
      end
      StoryEditorScreen.instance
    end

    def dispose!
      StoryEditorScreen.instance = nil
    end
  end

  def on_load
    rmq(self.view).apply_style(:root)

    @player = rmq.unshift!(SceneEditor, :scene_editor)

    @editable  = {}
    @edit_info = {}

    if app.development? || app.ad_hoc_release?
      @logger = rmq(self.view).append(StoryLoggerView).tag(:logger).get
      rmq(@player).append(@logger) unless @logger.nil?
    end

    @toolbox = rmq(self.view).append(StoryEditorToolbox).tag(:toolbox).get
    @toolbox.set_editor(self)
    rmq(@toolbox).hide
    rmq(@player).append(@toolbox) unless @toolbox.nil?

    @level = 1
    @screen = 1

    @change_screen_box = rmq(self.view).append(StoryEditorChangeScreenBox).tag(:change_screen_box).get
    @change_screen_box.hide
    @change_screen_box.set_editor(self)
    rmq(@player).append(@change_screen_box) unless @change_screen_box.nil?

    @edit_object_box = rmq(self.view).append(StoryEditorToolboxOld).tag(:edit_object_box).get
    @edit_object_box.hide
    rmq(@player).append(@edit_object_box) unless @edit_object_box.nil?

    @move_view = rmq(self.view).append(MoveObjectView).tag(:move_view).get
    @move_view.set_editor(self)
    @move_view.hide
    rmq(@player).append(@move_view) unless @move_view.nil?
  end

  def will_appear

    scene  = SceneFactory.create_scene(@story_bundle, ':level[1]:screen[1]')
    @editable = @story_bundle.ruleset.editable_objects_for_screen( @story_bundle, ':level[1]:screen[1]')
    setup_editor_mode(scene)

    @logger.clear! unless @logger.nil?
    @toolbox.hide  unless @toolbox.nil?

    @player.presentScene(nil)
    @player.presentScene(scene)

    NSNotificationCenter.defaultCenter.removeObserver(self)
    NSNotificationCenter.defaultCenter.addObserver(self,
                                                  selector: 'on_screen_event:',
                                                  name: 'screen_exit_event',
                                                  object: nil)
    NSNotificationCenter.defaultCenter.addObserver(self,
                                                  selector: 'on_editor_tap:',
                                                  name: 'on_editor_tap',
                                                  object: nil)
    NSNotificationCenter.defaultCenter.addObserver(self,
                                                  selector: 'on_editor_swipe:',
                                                  name: 'on_editor_swipe',
                                                  object: nil)
    JavaScript::Runtime.prepare_for(@story_bundle, scene)
  end

  def on_appear
    #JavaScript::Runtime.send_event(@player.scene.name, :at_load)
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

    @story_bundle.document.body.levels.each do |l|
      puts write_level_changes(l)
      l.screens.each do |s|
        puts write_screen_changes(s)
        s.objects.each do |o|
          puts write_object_changes(o)
        end
      end
    end

    @story_bundle = nil
    JavaScript::Runtime.tear_down
  end

  def show_scene_with_level( level, screen: screen)
    target = ':level[' + level.to_s + ']:screen[' + screen.to_s + ']'

    new_scene = SceneFactory.create_scene(@story_bundle, target)

    if new_scene.nil?
      lp [target + "doesnt exists, stay at the current level and screen"]
      return
    end
    transition_image = create_transition_image

    unless @player.scene.nil?
      @player.scene.removeAllChildren
      @player.scene.removeAllActions
      @player.scene.removeFromParent
    end
    @player.presentScene(nil)

    @editable = @story_bundle.ruleset.editable_objects_for_screen(@story_bundle, target)

    scene = new_scene

    setup_editor_mode(scene)
    scene.addChild(transition_image)

    @player.presentScene(scene)
    @level = level
    @screen = screen
    JavaScript::Runtime.get.scene_root = scene
  end

  def on_editor_tap(notification)
    # lp ["on_editor_tap:", notification.userInfo]

    @edit_info = {}
    @edit_info = notification.userInfo

    rmq(:change_screen_box).get.hide
    rmq(:edit_object_box).get.hide

    # toogle toolbox
    if(rmq(:toolbox).get.hidden?)
      open_toolbox
    else
      rmq(:toolbox).map do |tb|
        tb.set_target(nil, node: nil, actions: nil)
        tb.hide
      end
    end

    #Dispatch::Queue.main.after(0.25) do
    #  self.view.becomeFirstResponder

    #  rmq(:toolbox).map { |tb| tb.hide }

    #  menu = UIMenuController.sharedMenuController
    #  menu.menuItems = menu_for_object(notification.userInfo[:object])
    #  menu.setTargetRect([notification.userInfo[:location], [ 1, 1 ]], inView: self.view)
    #  menu.setMenuVisible(true, animated: true)
    #end

  end

  def on_editor_swipe(notification)
    #lp ["on_editor_swipe:", notification.userInfo]
  end

  def change_screen
    rmq(:toolbox).get.hide

    lp "Editor: change level and screen"

    rmq(:change_screen_box).map do |csb|
      csb.show
    end
  end

  def close_editor
    rmq(:toolbox).get.hide

    lp "Editor: is closing"

    close
  end

  #
  # Mark: UIResponder
  #
  def canBecomeFirstResponder
    true
  end

  def canPerformAction(action, withSender: sender)
    [:edit_object, :move_object, :close_editor, :change_screen].include? action.to_sym
  end

  #
  #
  #
  def edit_object
    rmq(:toolbox).get.hide

    path = @edit_info[:object]
    node = @player.node_for_path(path)
    object = @story_bundle.object_for_path(path)
    actions = @editable[path]

    lp "Editor: editing object -->  #{object.name}"

    rmq(:edit_object_box).map do |eob|
      eob.set_target(object, node:node, actions:actions)
      eob.show(@edit_info[:location])
    end
  end

  #
  #
  #
  def move_object
    rmq(:toolbox).get.hide

    path = @edit_info[:object]
    node = @player.node_for_path(path)
    object = @story_bundle.object_for_path(path)
    actions = @editable[path]

    lp "Editor: moving object -->  #{object.name}"

    rmq(:move_view).map do |mv|
      mv.set_target(object, node:node, actions: actions)
      mv.show(@edit_info[:location])
    end
  end

  #
  #
  #
  def open_toolbox
    path = @edit_info[:object]
    node = @player.node_for_path(path)
    object = @story_bundle.object_for_path(path)
    actions = @editable[path]

    rmq(:toolbox).map do |tb|
      tb.set_target(object, node: node, actions: actions)
      tb.show(@edit_info[:location])
    end
  end

  def update_toolbox_selected_node(path)
    lp @edit_info
    @edit_info = {:location => @player.node_for_path(path).position, :object => path}
    lp @edit_info
    path = @edit_info[:object]
    node = @player.node_for_path(path)
    object = @story_bundle.object_for_path(path)
    actions = @editable[path]

    rmq(:toolbox).map do |tb|
      tb.hide
      tb.set_target(object, node: node, actions: actions)
      tb.show(node.position)
    end
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

  def setup_editor_mode(scene)
    scene.backgroundColor = rmq.color.white
    scene.enumerateChildNodesWithName('//*', usingBlock: ->(node, _){
      if @editable.has_key? node.name
        node.alpha = 1.0
        node.zPosition += 999_800 if node.zPosition < 999_800 # ensure editable nodes are always on top
        node.size = CGSize.new(25, 25) if node.size.width < 25
      else
        node.alpha = 0.25
      end
    })
  end

  def menu_for_object(path)
    object  = @story_bundle.object_for_path(path)
    actions = @editable[path]

    items = []

    items << UIMenuItem.alloc.initWithTitle('Editor beenden', action: :close_editor)
    items << UIMenuItem.alloc.initWithTitle('Seite wechseln', action: :change_screen)

    return items if object.nil? or actions.nil?

    if actions[:object_name]  || actions[:object_content] ||
       actions[:size_x]       || actions[:size_y]         ||
       actions[:transparency] || actions[:layer]
      items << UIMenuItem.alloc.initWithTitle('Ändern...', action: :edit_object)
    end

    if actions[:position_x] || actions[:position_y]
      items << UIMenuItem.alloc.initWithTitle('Bewegen', action: :move_object)
    end

    items
  end

  def write_level_changes(level)
    res = "/* additional screens */\n"
    level.changes.each do |change|
      res += "copy('#{change}');\n"
    end
    res
  end

  def write_screen_changes(screen)
    res = "/* additional objects */\n"
    screen.changes.each do |change|
      res += "copy('#{change}');\n"
    end
    res
  end

  def write_object_changes(object)
    changes = []
    object.changes.each do |key, val|
      next if val[:value].nil?
      #changes << "\t#{key.to_s}: #{val[:value].is_a? String ? '\'' : ''}#{val[:value]}#{val[:value].is_a? String ? '\'' : ''}"
      if val[:value].is_a? String
        changes << "\t#{key.to_s}: '#{val[:value].gsub(/'/, '\\\\\'')}'"
      else
        changes << "\t#{key.to_s}: #{val[:value]}"
      end
    end

    unless changes.empty?
      "/* update #{object.path} */\n" + \
      "change('#{object.path}', {\n#{changes.join(",\n")}\n});\n"
    end
  end

  # Mark: media chooser helpers

  public

  # @private
  def media_chooser_popup_anchor
    res = nil
    rmq(:edit_object_box).map { |tb| res = tb.media_chooser_popup_anchor }
    res
  end

  # @private
  def photo_available( image )
    rmq(:edit_object_box).map { |tb| tb.photo_available(image) }
  end

  # @private
  def photo_canceled
    rmq(:edit_object_box).map { |tb| tb.photo_canceled }
  end
  # @private
  def video_available( media_url )
    rmq(:edit_object_box).map { |tb| tb.video_available(media_url) }
  end

  # @private
  def video_canceled
    rmq(:edit_object_box).map { |tb| tb.video_canceled }
  end
end

