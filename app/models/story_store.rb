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
    reload
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

      main_json = File.join( bundle_path, 'SMIL', 'control.json' )
      next unless File.exists?( main_json )

      raw = NSData.dataWithContentsOfFile( main_json, options: NSDataReadingMappedIfSafe, error: error_ptr )
      if raw.nil?
        NSLog( "Error while trying to read #{File.basename( main_json )}: #{error_ptr[0].localizedDescription}" )
      else
        data = NSJSONSerialization.JSONObjectWithData( raw, options: NSJSONReadingMutableLeaves, error: error_ptr)
        if data.nil?
          NSLog( "Error while trying to parse #{File.basename( main_json )}: #{error_ptr[0].localizedDescription}" )
        else
          res << Babbo::Document.new( data, bundle_path )
        end
      end
    end
    # simple way to get a sortable number from the timestamp
    @stories = res.sort_by { |x| x.timestamp }
  end
end

