class StoryBundle
  attr_reader :document, :load_errors

  # Initialize a new +StoryBundle+.
  # A freshly allocated +StoryBundle+ is invalid until it's
  # +#load+ method is called.
  #
  # @param [String] bundle_path The absolute path to the bundle.
  def initialize( bundle_path )
    @path  = bundle_path
    @paths = nil
    @valid = false
    @load_errors = []
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

    mp "Read control data from: '#{control_path}'"
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

    mp "#{File.basename(control_path)} contains a valid document."
    @document = document
  end

  # Collect all assets referenced in this story and
  # if everything is available add them to the +AssetStore+
  def collect_and_cache_assets
    # Assets are only contained in objects
    mp 'Collecting assets..'
    asset_list = []
    @document.body.levels.each do |level|
      level.screens.each do |screen|
        screen.objects.each do |object|
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

    if @load_errors.empty?
      asset_store = AssetStore.new
      asset_list.each do |asset|
        mp "Caching '#{asset}'..", force_color: :yellow if app.development?

        unless asset_store.cache_resource(asset)
          @load_errors << "Failed to cache asset '#{asset}'"
        end
      end
      asset_store.compact!
      mp "Cached #{asset_list.count} assets."
    end
  end
end

