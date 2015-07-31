class StoryStore
  # Root path inside the +Documents+ folder which will hold all *.babbo-bundles.
  STORY_ROOT = 'Bundles'

  # @return [Array<Hash>] An +Array+ containing one +Hash+ for each loaded story bundle.
  attr_reader :stories

  class << self
    def shared_store
      @store ||= StoryStore.new
    end
  end

  def initialize

  end

  # Check the available stories in the Applications NSDocumentDirectory
  # @return [Array<Hash>] An +Array+ containing +Hash+ objects each of which represents the +control.json+ of a story bundle.
  # @return [Array] An empty +Array+ if any errors occur. The specific error will be reported via NSLog.
  def reload
    error_ptr = Pointer.new( :object )
    file_manager = NSFileManager.defaultManager

    # setup the STORY_ROOT class variable (once)
    @@STORY_ROOT ||= begin
      # make sure the Documents path exists
      documents_root = file_manager.URLForDirectory( NSDocumentDirectory, inDomain: NSUserDomainMask,
                                                     appropriateForURL: nil, create: true, error: error_ptr )
      story_root = nil
      if documents_root
        story_root = documents_root.URLByAppendingPathComponent( STORY_ROOT )
        unless file_manager.createDirectoryAtURL( story_root, withIntermediateDirectories: true, attributes: nil, error: error_ptr )
          story_root = nil
        end
      end
      story_root
    end

    if @@STORY_ROOT.nil?
      # something went wrong
      NSLog( "Error while trying to setup STORY_ROOT: #{error_ptr[0].localizedDescription}" )
      return []
    end

    # fetch a list of all .babbo bundles inside STORY_ROOT and load their JSON
    res = []
    Dir.glob( File.join( @@STORY_ROOT.fileSystemRepresentation, '*.babbo' ) ).each do |bundle_path|
      # skip all uninteresting entries
      next unless File.directory?( bundle_path )
      next unless File.extname( bundle_path ) == '.babbo'

      mp "Processing: #{bundle_path}", force_color: :red

      # collect files inside the bundle
      main_json = File.join( bundle_path, 'SMIL', 'control.json' )
      mods_json = File.join( bundle_path, 'SMIL', 'changes.json' )
      next unless File.exists?( main_json )

      main_data = load_json_file( main_json, false )
      schema    = load_schema_definition()
      rules     = load_splicer_rules( bundle_path )

      next if schema.nil?

      if File.exists? mods_json
        mods_data = load_json_file( mods_json, false )
      else
        # this wil result in a no-op merge but causes the resulting
        # document to be augmented with a '__modifiable' key
        mods_data = {}
      end

      if rules.nil?
        data = main_data
      else
        begin
          # TODO: handle exceptions..
          data = TypeMonkey::Splicer::splice( schema, rules, 'smil_document',
                                              main_data, mods_data )
        rescue => e
          NSLog( "Skip.." )
          next
        end
      end

      begin
        TypeMonkey::Validator::validate( schema, data, 'smil_document' )
      rescue => e
        NSLog( "Skip 2.." )
        next
      end

      res << Babbo::Document.new( data, bundle_path )
    end
    # simple way to get a sortable number from the timestamp
    @stories = res.sort_by { |x| x.timestamp }
  end

  private

  def load_schema_definition
    @schema ||= begin
      path = NSBundle.mainBundle.pathForResource( 'rules-local', ofType: 'json' )
      data = load_json_file( path, false )
      if data.nil?
        nil
      else
        begin
        # TODO: handle exceptions..
          TypeMonkey::Schema::parse( data )
        rescue TypeMonkey::Schema::Error => e
          NSLog( "Failed to load schema definition" )
          nil
        end
      end
    end
  end

  def load_splicer_rules( bundle_path )
    path = File.join( bundle_path, 'SMIL', 'rules-splice.json' )
    return nil unless File.exists? path

    data = load_json_file( path, false )
    if data.nil?
      nil
    else
      # TODO: handle exceptions
      begin
        mapping = load_splicer_mapping
        TypeMonkey::Splicer::parse( data, mapping )
      rescue TypeMonkey::Splicer::Error => e
        NSLog( "Failed to load splicer rules." )
        nil
      end
    end
  end

  def load_splicer_mapping
    @mapping ||= begin
      path = NSBundle.mainBundle.pathForResource( 'splice-mapping', ofType: 'json' )
      load_json_file( path )
    end
  end

  def load_json_file( path, read_only=true )
    error_ptr = Pointer.new( :object )
    raw = NSData.dataWithContentsOfFile( path, options: NSDataReadingMappedIfSafe, error: error_ptr )
    if raw.nil?
      error = error_ptr[0]
      NSLog( "Error while trying to read '#{File.basename(path)}': #{error.localizedDescription}" )
      nil
    else
      options = read_only ? 0 : ( NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves )
      data = NSJSONSerialization.JSONObjectWithData( raw, options: options, error: error_ptr )
      if data.nil?
        error = error_ptr[0]
        NSLog( "Error while parsing '#{File.basename(path)}': #{error.localizedDescription}" )
        return nil
      end
      data
    end
  end
end

