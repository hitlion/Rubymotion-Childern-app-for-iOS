class StoryBundle
  class << self
    attr_accessor :bundle_list
    # Return the (cached) bundle list.
    # If the list was not loaded it will be initialized on first
    # request.
    #
    # @param [Hash] args Optional parameters
    # @option [Boolean] args :reload Force a reload from disk
    # @option [Boolean] args :async Perform asynchronous loading
    #   in the background (will return an empty list on first call).
    # @option [Proc] args :callback For use in combination with :async.
    #   Expects a callback of the form cb(total, loaded) to be called
    #   when background loading progresses.
    # @return [Array<StoryBundle>] The list of available
    #   story bundles.
    def bundles( args={} )
      async_load = args.fetch(:async, false)
      async_cb   = args.fetch(:callback, nil)

      if self.bundle_list.nil? || args.fetch(:reload, false)
        bundle_root = File.join(Dir.system_path(:documents), 'Bundles')
        Dir::mkdirs(bundle_root) unless Dir.exist? bundle_root

        self.bundle_list = []
        if async_load
          weak_self = WeakRef.new(self)
          Dispatch::Queue.concurrent.async do
            bundle_count = Dir.glob("#{bundle_root}/*.babbo").count
            async_cb.call(bundle_count, weak_self.bundle_list.count) unless async_cb.nil?

            Dir.glob("#{bundle_root}/*.babbo").each do |bundle_path|
              autorelease_pool{
                bundle = StoryBundle.new(bundle_path)
                bundle.load
                weak_self.bundle_list << bundle if !bundle.has_changesets?
                weak_self.bundle_list << bundle.changesets if bundle.has_changesets?
                async_cb.call(bundle_count, weak_self.bundle_list.count) unless async_cb.nil?
              }
            end
          end
        else
          Dir.glob("#{bundle_root}/*.babbo").each do |bundle_path|
            autorelease_pool{
              bundle = StoryBundle.new(bundle_path)
              bundle.load
              self.bundle_list << bundle if !bundle.has_changesets?
              self.bundle_list << bundle.changesets if bundle.has_changesets?
            }
          end
        end
      else
        if async_load
          count = self.bundle_list.count
          Dispatch::Queue.concurrenc.async { async_cb.call(count, count) unless async_cb.nil? }
        end
      end
      self.bundle_list
    end

    def delete_story(story)
      self.bundle_list.delete(story)

      NSNotificationCenter.defaultCenter.postNotificationName('BabboBundleChanged',
                                                              object:nil,
                                                              userInfo: {
                                                                  :changed_bundle => story,
                                                                  :status => :deleted
                                                              })
      app.alert(title: "Story gelöscht!", message: "Die Story #{story.document.set_name} wurde erfolgreich gelöscht.", actions: ['OK'])
    end

    def reload_bundle(story, path)
      StoryBundle.delete_story(story)
      StoryBundle.add_new_bundle(path)
    end

    def add_new_bundle(path)
      autorelease_pool{
        bundle = StoryBundle.new(path)
        bundle.load
        story = nil
        if !bundle.has_changesets?
          self.bundle_list << bundle
          story = bundle
        end

        if bundle.has_changesets?
          self.bundle_list << bundle.changesets
          story = bundle.changesets
        end

        NSNotificationCenter.defaultCenter.postNotificationName('BabboBundleChanged',
                                                                object:nil,
                                                                userInfo: {
                                                                    :changed_bundle => story,
                                                                    :status => :added
                                                                })
        app.alert(title: "Neue Story!", message: "Die Story #{story.document.set_name} wurde erfolgreich hinzugefügt.", actions: ['OK'])
      }
    end

    def get_bundle_with_identifier(identifier)
      return nil unless identifier

      story = nil
      self.bundle_list.each do |bundle|
        if(bundle.productIdentifier)
          story = bundle if identifier == bundle.productIdentifier
        end
      end

      return story
    end

    def bundle_with_identifier_installed? (identifier)
      return false unless identifier

      installed = false

      self.bundle_list.each do |bundle|
        if(bundle.productIdentifier)
          installed = true if identifier == bundle.productIdentifier
        end
      end

      return installed
    end
  end

  attr_reader :document, :load_errors, :path, :ruleset, :changelog, :screenshots, :screenshot_urls, :thumbnail, :description

  # Initialize a new +StoryBundle+.
  # A freshly allocated +StoryBundle+ is invalid until it's
  # +#load+ method is called.
  #
  # @param [String] bundle_path The absolute path to the bundle.
  def initialize( bundle_path )
    @path  = bundle_path
    @paths = nil
    @valid = false
    @ruleset = nil
    @load_errors = []
    @changelog = nil
    @screenshots = nil
    @thumbnail = nil
    @description = nil

    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector: 'screenshot_urls_received:',
                                                   name: 'BackendScreenshotURLReceived',
                                                   object: nil)
  end

  def copy
    new = StoryBundle.new(self.path)
    new.load

    if(new.has_changesets?)
      new = new.changesets
    end

    return new
  end

  # Check if this level is valid.
  # A freshly created level is always invalid and can only become
  # valid once it's +load+ method was successfully called.
  def valid?
    @valid
  end

  # Load the control data and cache all assets associated with
  # this +StoryBundle+
  #
  # @return [Boolean] +true+ if the +StoryBundle+ is valid ond complete.
  #   +false+ on errors or if assets are missing. See the +load_errors+
  #   property for details.
  def load
    return false if valid?

    load_story_definition
    return false unless @load_errors.empty?

    collect_and_cache_assets
    @valid = true if @load_errors.empty?

    load_ruleset

    #load_editable_list # call this function here is to memory consuming for weak devices, better call when open the editor.
    valid?
  end

  # Return the story object for a given +path+
  #
  # @param [String] path The story path for the requested object.
  # @return [Object] The coresponding story object or +nil+ if no
  #   object for that path exists in the document.
  def object_for_path( path )
    return nil unless valid?

    @paths ||= begin
      # create a lazy cache for all available paths on first use.
      paths = { @document.body.path => WeakRef.new(@document.body) }

      @document.body.levels.each do |level|
        paths[level.path] = WeakRef.new(level)

        level.screens.each do |screen|
          paths[screen.path] = WeakRef.new(screen)

          screen.objects.each do |object|
            paths[object.path] = WeakRef.new(object)
          end
        end
      end
      paths
    end
    @paths[path]
  end

  # Return a +NSData+ object for the assec at +path+
  #
  # @param [String] path The relative asset path inside the bundle.
  # @return [NSData] The assects data or +nil+ if an error occurs.
  def asset_data( path )
    return nil unless valid?

    # relative paths are specified from inside the SMIL directory
    if path.start_with? '../'
      path = File.absolute_path(File.join(@path, 'SMIL', path))
    end

    if File.exists? path
      NSData.dataWithContentsOfFile(path)
    else
      nil
    end
  end

  # Return the absolute path to the asset +path+
  # @param [String] path The asset path relative to the bundle.
  # @return [String] The absolute asset path or +nil+ if the bundle is
  #   invalid.
  def asset_path( path )
    return nil unless valid?

    # relative paths are specified from inside the SMIL directory
    if path.start_with? '../'
      File.absolute_path(File.join(@path, 'SMIL', path))
    else
      # TODO: different handling?
      path
    end
  end

  # Return a relative path for a new asset of +type+
  # @param [Symbol] type The type for the new asset.
  #   One of :video, :picture, :audio
  # @return [String] The relative asset path or +nil+ if the bundle is
  #   invalid or if any error occured.
  def asset_path_for_new_item_of_type( type )
    return nil unless [:video, :picture, :audio].include? type

    base_name = NSUUID.UUID.UUIDString
    case type
    when :video
      File.join('..', 'content', "#{base_name}.m4v")
    when :picture
      File.join('..', 'content', "#{base_name}.png")
    when :audio
      File.join('..', 'content', "#{base_name}.m4a")
    else
      nil
    end
  end

  # Return a list of +StoryBundle+ objects containing
  # one item for each changeset located in the bundles data directory.
  # @return [Array<StoryBundle>] A list of modified version of this bundle
  #   matching the changesets located inside of the bundle.
  def changesets
    changesets = nil
    return changesets unless valid?

    control_path = File.absolute_path(File.join(@path, 'SMIL'))
    runner = Story::Changelog::Runner.new
    bundle = nil

    i = 0
    Dir.glob(File.join(control_path, 'changes_branch_*.js')).each_with_index do
      i+=1
    end

    if(i > 0)
      name = 'changes_branch_' + i.to_s + '.js'
      change_data = File.read(File.join(control_path, name))

      unless change_data.nil?
        # bundle = Marshal.load(Marshal.dump(self)) # doesnt work in ios 9 or higher? body slot were missing after this
        bundle = self.clone
        runner.apply(bundle, change_data)
        # bundle.document.dataset_id = -1 * index if bundle.document.dataset_id == self.document.dataset_id
        bundle.instance_eval { @changelog = change_data }
      end
    end

    changesets = bundle
    changesets
  end

  # Check if the bundle contains any changesets.
  # @return [Boolean] +true+ if the bundle has changesets available
  #   +false+ otherwise.
  def has_changesets?
    return false unless valid?

    control_path = File.absolute_path(File.join(@path, 'SMIL'))
    ! Dir.glob(File.join(control_path, 'changes_branch_*.js')).empty?
  end

  def load_editable_views
     @ruleset.editable_screens
  end

  # Collect all levels and screens with editable object in an array
  def load_editable_list_for_screen(path)
    editable = []

    autorelease_pool{
      editable = @ruleset.editable_objects_for_screen(self, path)
    }

    editable
  end

  # This method return the screenshots for this shop object,
  # if it is already loaded and cached from the backend.
  # Otherwise this method send a request for the paths (URLs) to the screenshots.
  # If the URLs are already received load the images. In both cases return nil.
  # @return [Array <UIImage>] an Array of UIImages or +nil+ if if loading and cache is not done
  def screenshots
    if(@screenshots.nil?)
      unless @screenshot_urls
        BabboBackend.get.request_screenshots_urls_for_identifier(@document.productIdentifier, sender:self)
        return nil
      else
        load_screenshots(@screenshot_urls)
        return nil
      end
    end

    return @screenshots
  end

  def set_name
    return self.document.set_name
  end

  def thumbnail
    if(@thumbnail.nil?)
      @thumbnail = UIImage.imageWithData(self.asset_data(self.document.thumbnail))
    end
    return @thumbnail
  end

  def timestamp
    return self.document.timestamp
  end

  def description
    return nil unless valid?

    if(@description.nil?)

      description = 'no text found'
      if self.document.description.start_with? '../'
        path = File.join(@path, File.absolute_path(self.document.description))
      end

      return nil unless File.exists? path
      file = YAML.load(File.read(path))

      if(file[:description])
        description = file[:description]
      end

      @description = description
    end

    return @description
  end

  def productIdentifier
    return nil unless self.document
    return self.document.productIdentifier
  end

  private

  # Load the story definition from `SMIL/control.[yml/json]`.
  # If a YAML file is present it will be prefered over JSON.
  #
  # Any errors while loading will be recorded in the `.load_errors`
  # property.
  def load_story_definition
    base_path = File.join(@path, 'SMIL')
    if File.exists? File.join(base_path, 'control.yml')
      control_path = File.join(base_path, 'control.yml')
      control_data = YAML.load(File.read(control_path))

    elsif File.exists? File.join(base_path, 'control.json')
      control_path = File.join(base_path, 'control.json')
      control_data = JSON.load(File.read(control_path))
    else
      @load_errors << 'Neither \'control.yml\' nor \'control.json\' in \'SMIL\' directory.'
      return
    end

    lp "Read control data from: '#{control_path}'"
    if control_data.nil?
      @load_errors << "Errors occured while trying to read '#{control_path}'."
      return
    end

    document = Story::Document.new
    document.load(Hash.symbolicate(control_data))

    unless document.valid?
      @load_errors += document.validation_errors
      document = nil
    end

    lp "#{File.basename(control_path)} contains a valid document."
    @document = document
    @manifest = File.absolute_path(control_path)
    autorelease_pool { @checksum = NSData.sha1FromContentsOfFile(@manifest)}
  end

  # Load the splice ruleset from `SMIL/splice-rules.[yml/json]`.
  # If a YAML file is present it will be prefered over JSON.
  #
  # Any errors while loading will result in an empty ruleset
  # which in turn produces an immutable document.
  def load_ruleset
    base_path = File.join(@path, 'SMIL')
    if File.exists? File.join(base_path, 'splice.yml')
      rules_path = File.join(base_path, 'splice.yml')
      rules_data = YAML.load(File.read(rules_path))

    elsif File.exists? File.join(base_path, 'splice.json')
      rules_path = File.join(base_path, 'splice.json')
      rules_data = JSON.load(File.read(rules_path))
    else
      @ruleset = Story::Changelog::Ruleset.new([])
      return
    end

    lp "Read ruleset data from: '#{rules_path}'"
    if rules_data.nil?
      lp "Ruleset data is empty or invalid", force_color: :red
      @ruleset = Story::Changelog::Ruleset.new([])
      return
    end

    @ruleset = Story::Changelog::Ruleset.new(rules_data)
  end

  # Collect all assets referenced in this story and
  # if everything is available add them to the +AssetStore+
  def collect_and_cache_assets
    # Assets are only contained in objects
    lp 'Collecting assets..'
    asset_list = []
    asset_store = AssetStore.new

    if asset_store.valid_manifest? @checksum
      lp 'Assets are still valid (checksum match).'
      asset_store.compact!
      return true
    end

    @document.body.levels.each do |level|
      level.screens.each do |screen|
        screen.objects.each do |object|

          if(object.type != :text)
            asset_path = object.content

            # relative paths are specified from inside the SMIL directory
            if asset_path.start_with? '../'
              asset_path = File.absolute_path(File.join(@path, 'SMIL', asset_path))
            end

            if File.exists? asset_path
              asset_list << asset_path
            else
              @load_errors << "Missing asset '#{object.content}' for '#{object.path}'"
            end
          end
        end
      end
    end

    if @load_errors.empty?
      asset_list.each do |asset|
        lp "Caching '#{asset}'..", force_color: :yellow if app.development?

        unless asset_store.cache_resource(asset)
          @load_errors << "Failed to cache asset '#{asset}'"
        end
      end
      asset_store.register_manifest(@manifest, @checksum)
      asset_store.compact!
      lp "Cached #{asset_list.count} assets."
    end
  end

  def send_screenshots_updated
    NSNotificationCenter.defaultCenter.postNotificationName('ShopObjectScreenshotsUpdated',
                                                            object:nil,
                                                            userInfo: {
                                                                identifier: @productIdentifier,
                                                                screenshots: @screenshots
                                                            })
  end

  # Receiver method for the screenshots callback
  def screenshot_urls_received(notification)
    return unless notification.userInfo[:sender] == self
    urls = notification.userInfo[:url]
    @screenshot_urls = []
    urls.each do |url|
      @screenshot_urls << url.to_url
    end
    load_screenshots(@screenshot_urls)
  end

  # Load the screenshots for this shop story
  # @param [String] url The URLs to the screenshots for this shop object
  def load_screenshots(urls)
    return false if urls.nil? || urls.empty?
    @screenshots = []

    Dispatch::Queue.concurrent.async do
      urls.each do |url|
        next unless url
        @screenshots = [] unless @screenshots
        image = UIImage.imageWithData(NSData.dataWithContentsOfURL(url))
        @screenshots << image if image
      end
      send_screenshots_updated
    end
  end
end

