class StoryEditorScreen < PM::Screen
  title 'Babbo Voco'
  stylesheet StoryEditorStylesheet

  include MediaChooseModule
  #include AudioRecorderModule
  include OrientationModule

  attr_accessor :story_bundle, :edit_mode, :original_bundle, :new_files, :obsolete_files
  attr_reader :current_view, :editable, :editable_views, :player

  class << self
    attr_accessor :instance

    def get( bundle, mode)

      StoryEditorScreen.instance ||= StoryEditorScreen.new(nav_bar: false)
      StoryEditorScreen.instance.edit_mode = mode
      unless bundle.nil?
        StoryEditorScreen.instance.original_bundle = bundle
        StoryEditorScreen.instance.story_bundle = bundle.copy
        StoryEditorScreen.instance.new_files = []
        StoryEditorScreen.instance.obsolete_files = []
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

    @editable_views = []
    @edit_info = {}

    if app.development? || app.ad_hoc_release?
      @logger = rmq(self.view).append(StoryLoggerView).tag(:logger).get
      rmq(@player).append(@logger) unless @logger.nil?
    end

    @toolbox = rmq(self.view).append(StoryEditorToolbox).tag(:toolbox).get
    rmq(@toolbox).hide
    rmq(@player).append(@toolbox) unless @toolbox.nil?

    @change_view_box = rmq(self.view).append(StoryEditorChangeViewBox).tag(:change_view_box).get
    @change_view_box.hide
    rmq(@player).append(@change_view_box) unless @change_view_box.nil?

    @edit_object_box = rmq(self.view).append(StoryEditorEditBox).tag(:edit_object_box).get
    @edit_object_box.hide
    rmq(@player).append(@edit_object_box) unless @edit_object_box.nil?

    @move_view = rmq(self.view).append(StoryEditorMoveObjectView).tag(:move_view).get
    @move_view.hide
    rmq(@player).append(@move_view) unless @move_view.nil?

    @audio_record_view = rmq(self.view).append(AudioRecordView).tag(:audio_record_view).get
    @audio_record_view.hide
    rmq(@player).append(@audio_record_view) unless @audio_record_view.nil?
  end

  def will_appear
    @editable_views = @story_bundle.load_editable_views

    scene  = SceneFactory.create_scene(@story_bundle, @editable_views.first, :editor)
    @editable = @story_bundle.ruleset.editable_objects_for_screen( @story_bundle, @editable_views.first)
    @current_view = @editable_views.first

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
    # ask for new name
    if(@edit_mode == :new)
      if(@original_bundle.document.set_name  == @story_bundle.document.set_name)
        app.alert(title: "Welchen Namen und welches Titelbild soll deine neue Story haben?", message: "Bitte Namen eingeben und dann ein Foto auswählen!", style: :custom, fields: {input: {placeholder: "Neuer Name"}}) do |_, fields|
          unless fields[:input].text.empty?
            name = fields[:input].text
          else
            name = 'Kopie von ' + @story_bundle.document.set_name
          end
          @story_bundle.document.set_name = name

          rmq.screen.present_photo_chooser(WeakRef.new(self))
        end
      end
    end

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

    JavaScript::Runtime.tear_down
  end

  def touchesBegan(touches, withEvent: event)
    touch = event.allTouches.anyObject
    location = touch.locationInView(@player)
    dest = @player.hitTest(location, withEvent: event)

    if(dest == self.player)
      setup_editor_mode(JavaScript::Runtime.get.scene_root)
      rmq(:change_view_box).get.hide
      rmq(:edit_object_box).get.hide
      rmq(:toolbox).get.hide
    end
    super
  end

  def show_scene(target)

    new_scene = SceneFactory.create_scene(@story_bundle, target, :editor)

    if new_scene.nil?
      lp "#{target} doesnt exists, stay at the current level and screen"
      return
    end
    # transition_image = create_transition_image

    unless @player.scene.nil?
      @player.scene.removeAllChildren
      @player.scene.removeAllActions
      @player.scene.removeFromParent
    end
    @player.presentScene(nil)

    @editable = @story_bundle.ruleset.editable_objects_for_screen(@story_bundle, target)

    scene = new_scene

    setup_editor_mode(scene)
    # scene.addChild(transition_image)

    @player.presentScene(scene)

    @current_view = target

    JavaScript::Runtime.get.scene_root = scene
  end

  def on_editor_tap(notification)
    # lp ["on_editor_tap:", notification.userInfo]

    @edit_info = {}
    @edit_info = notification.userInfo

    rmq(:change_view_box).get.hide
    rmq(:edit_object_box).get.hide

    # toogle toolbox
    if(rmq(:toolbox).get.hidden?)
      open_toolbox
    else
      # this lines arent reached because of line 132
      rmq(:toolbox).map do |tb|
        tb.set_target(nil, node: nil, actions: nil)
        tb.hide
      end
    end
  end

  def on_editor_swipe(notification)
    #lp ["on_editor_swipe:", notification.userInfo]
  end

  def change_view
    rmq(:toolbox).get.hide

    lp "Editor: change level and screen"

    rmq(:change_view_box).map do |csb|
      csb.show
    end
  end

  def close_editor
    rmq(:toolbox).get.hide

    lp "Editor: is closing"

    # check for changes
    changes =  @story_bundle.document.has_changes?
    lp "Editor: Changes exists: #{changes}"

    app.alert(title: "Achtung!", message: "Wollen sie speichern?", actions: ['Speichern', 'Ohne speichen beenden', 'Zurück zum Editor'] ) do |button_tag|
      case button_tag
        when 'Speichern'
          if(changes)
            save_changes
          else
            @obsolete_files = []
            close
          end

        when 'Ohne speichen beenden'
          @obsolete_files = []
          close
        when 'Zurück zum Editor'

      end
    end
  end

  #
  # Mark: UIResponder
  #
  def canBecomeFirstResponder
    true
  end
 # obsolete
 # def canPerformAction(action, withSender: sender)
 #   [:edit_object, :move_object, :close_editor, :change_view].include? action.to_sym
 # end

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

  def record_audio(path, delegate)
    rmq(:edit_object_box).get.hide
    @audio_record_view.show(path, delegate)
  end

  #
  #
  #
  def open_toolbox
    path = @edit_info[:object]
    node = @player.node_for_path(path)
    object = @story_bundle.object_for_path(path)
    actions = @editable[path]

    if(node)
      scene = JavaScript::Runtime.get.scene_root

      scene.enumerateChildNodesWithName('//:*', usingBlock: ->(n, _){

        if n.name == node.name

        else
          n.alpha = 0.10
          n.zPosition -= 999_800 if n.zPosition > 999_800
        end
      })
    end

    rmq(:toolbox).map do |tb|
      tb.set_target(object, node: node, actions: actions)
      tb.show(@edit_info[:location])
    end
  end

  def update_toolbox_selected_node(path)
    @edit_info = {:location => @player.node_for_path(path).position, :object => path}
    path = @edit_info[:object]
    node = @player.node_for_path(path)
    object = @story_bundle.object_for_path(path)
    actions = @editable[path]

    scene = JavaScript::Runtime.get.scene_root

    scene.enumerateChildNodesWithName('//:*', usingBlock: ->(n, _){
      if n.name == node.name
        n.alpha = 1
        n.zPosition += 999_800
      else
        n.alpha = 0.05
        n.zPosition -= 999_800 if n.zPosition > 999_800
      end
    })
    rmq(:toolbox).map do |tb|
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
    scene.enumerateChildNodesWithName('//:*', usingBlock: ->(node, _){
      if @editable.has_key? node.name
        node.alpha = 1.0
        node.zPosition += 999_800 if node.zPosition < 999_800 # ensure editable nodes are always on top
        if(defined? node.size)
          node.size = CGSize.new(25, 25) if node.size.width < 25
        end
      else
        node.alpha = 0.10
      end
    })
  end

  def write_meta_changes(bundle)
    story = bundle.document
    res = "/* new meta informations */\n"
    res += "meta('#{story.dataset_id.to_s}', '#{story.set_name.to_s}', '#{story.thumbnail.to_s}', '#{story.timestamp.to_s}', '#{story.productIdentifier.to_s}', '#{story.status.to_s}');\n"
    res
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

  def close
    lp "New Files:"
    @new_files.each do |path|
      lp path
      NSFileManager.defaultManager.removeItemAtPath(path, error: nil)
    end

    lp "Obsolete Files"
    @obsolete_files.each do |path|
      lp path
      NSFileManager.defaultManager.removeItemAtPath(path, error: nil)
    end

    @new_files = nil
    @obsolete_files = nil

    @story_bundle.document.reset_changes
    @story_bundle = nil
    @original_bundle = nil
    super
  end

  # Mark: media chooser helpers

  public

  # @private
  def media_chooser_popup_anchor
    res = nil
    if(rmq(:edit_object_box).get.show?)
      rmq(:edit_object_box).map { |tb| res = tb.media_chooser_popup_anchor }
    else
      res = rmq.screen.view
    end
    res
  end

  # @private
  def photo_available( image, new )
    path = rmq.screen.story_bundle.asset_path_for_new_item_of_type(:picture)
    @story_bundle.document.thumbnail = path
    @new_thumbnail = image
  end

  # @private
  def photo_canceled

  end

  # @private
  def video_available( media_url, new )

  end

  # @private
  def video_canceled

  end

  def audio_available( media_url )
  end

  def audio_canceled
  end

  def save_changes
    # edit or new story --> set paths and file
    @path = @story_bundle.path

    @story_bundle.document.status = :V2

    if(@edit_mode == :edit)
      lp "Editor: save edited story as new version"
    else
      lp "Editor: save edited story as new story"

      dir = File.split(@story_bundle.path).first
      source = File.split(@story_bundle.path).last
      name = source.split('.').first
      source_id = name.split('_')[1]
      name = name.split('_').first

      count = 0

      # count how many version exists
      Dir.glob(File.join(dir,name + '_*_*.babbo')).each_with_index do
        count += 1
      end

      @story_bundle.document.dataset_id = count+1
      @story_bundle.document.productIdentifier = @story_bundle.document.productIdentifier + "_#{@story_bundle.document.dataset_id}"

      dest_name = name + '_' + count.to_s + '_' + source_id.to_s + '.babbo'
      lp "Editor: new directory name: #{dest_name}"
      new_path = File.join(dir, dest_name)
      NSFileManager.defaultManager.copyItemAtPath(@path, toPath: new_path, error: nil)
      @path = new_path
    end

    #load and save new thumbnail

    if(@new_thumbnail)
      path = File.absolute_path(File.join(@path, 'SMIL', @story_bundle.document.thumbnail))
      UIImagePNGRepresentation(@new_thumbnail).writeToFile(path, atomically: true)
    end

    if(@story_bundle.document.dataset_id > 0)
      @story_bundle.document.dataset_id = -1 * @story_bundle.document.dataset_id
    end

    @story_bundle.document.timestamp = Time.now.strftime("%FT%T%:z").to_s

    base_path = File.join(@path, 'SMIL')
    count = 1
    Dir.glob(File.join(base_path, 'changes_branch_*.js')).each_with_index do
      count = count + 1
    end

    name = "changes_branch_#{count.to_s}.js"
    base_path = File.join(base_path, name)
    file = File.new(base_path, "w")
    lp "Editor: create branch file #{name}"

    puts write_meta_changes(@story_bundle)
    file.write(write_meta_changes(@story_bundle))

    @story_bundle.document.body.levels.each do |l|
      puts write_level_changes(l)
      file.write(write_level_changes(l))
      l.screens.each do |s|
        file.write(write_screen_changes(s))
        puts write_screen_changes(s)
        s.objects.each do |o|
          file.write(write_object_changes(o))
          puts write_object_changes(o)
        end
      end
    end

    @new_files = []

    if(edit_mode == :edit)
      StoryBundle.reload_bundle(@original_bundle, @path)
    else
      StoryBundle.add_new_bundle(@path)
    end

    close
  end
end

