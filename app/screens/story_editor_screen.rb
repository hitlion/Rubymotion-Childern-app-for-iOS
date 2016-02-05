class StoryEditorScreen < PM::Screen
  title 'Babbo Voco'
  stylesheet StoryEditorStylesheet

  attr_accessor :story_bundle

  class << self
    attr_accessor :instance

    def get( bundle )
      StoryEditorScreen.instance ||= StoryEditorScreen.new(nav_bar: false)
      unless bundle.nil?
        StoryEditorScreen.instance.story_bundle = bundle
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
    rmq(@toolbox).hide
    rmq(@player).append(@toolbox) unless @toolbox.nil?
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
      l.screens.each do |s|
        s.objects.each do |o|
          lp write_object_changes(o)
        end
      end
    end

    @story_bundle = nil
    JavaScript::Runtime.tear_down
  end

  def on_screen_event( notification )
    info = Hash.symbolicate(notification.userInfo || {})
    Dispatch::Queue.main.async do
      if info.has_key? :exit_to
        show_scene(info[:exit_to])
      else
        close
      end
    end
  end

  def show_scene( target )
    transition_image = create_transition_image

    unless @player.scene.nil?
      @player.scene.removeAllChildren
      @player.scene.removeAllActions
      @player.scene.removeFromParent
    end
    @player.presentScene(nil)

    scene  = SceneFactory.create_scene(@story_bundle, target)
    @editable = @story_bundle.ruleset.editable_objects_for_screen(@story_bundle, target)

    if scene.nil?
      # FIXME
      lp "bailouto"
      return
    end
    setup_editor_mode(scene)
    scene.addChild(transition_image)

    @player.presentScene(scene)

    JavaScript::Runtime.get.scene_root = scene
  end

  def on_editor_tap(notification)
    lp ["on_editor_tap:", notification.userInfo]

    @edit_info = {}
    rmq(:toolbox).map do |tb|
      tb.set_target(nil, node: nil, actions: nil)
      tb.hide
    end

    if notification.userInfo[:object]
      return unless @editable.has_key? notification.userInfo[:object]

      @edit_info = notification.userInfo
      Dispatch::Queue.main.after(0.25) do
        self.view.becomeFirstResponder

        rmq(:toolbox).map { |tb| tb.hide }

        menu = UIMenuController.sharedMenuController
        menu.menuItems = menu_for_object(notification.userInfo[:object])
        menu.setTargetRect([notification.userInfo[:location], [ 1, 1 ]], inView: self.view)
        menu.setMenuVisible(true, animated: true)
      end
    end
  end

  def on_editor_swipe(notification)
    lp ["on_editor_swipe:", notification.userInfo]
  end

  #
  # Mark: UIResponder
  #
  def canBecomeFirstResponder
    true
  end

  def canPerformAction(action, withSender: sender)
    [:edit_object, :move_object].include? action.to_sym
  end

  #
  #
  #
  def edit_object
    path = @edit_info[:object]
    node = @player.node_for_path(path)
    object = @story_bundle.object_for_path(path)
    actions = @editable[path]

    rmq(:toolbox).map do |tb|
      tb.set_target(object, node: node, actions: actions)
      tb.show(@edit_info[:location])
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

    return [] if object.nil? or actions.nil?

    items = []
    if actions[:object_name]  || actions[:object_content] ||
       actions[:size_x]       || actions[:size_y]         ||
       actions[:transparency] || actions[:layer]
      items << UIMenuItem.alloc.initWithTitle('Ändern..', action: :edit_object)
    end

    if actions[:position_x] || actions[:position_y]
      items << UIMenuItem.alloc.initWithTitle('Bewegen', action: :move_object)
    end
    items
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
      "change('#{object.path}', {\n#{changes.join(",\n")}\n});\n"
    end
  end
end

