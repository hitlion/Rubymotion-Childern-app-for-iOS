class StoryListViewController < UITableViewController
  STORY_ROOT = 'Bundles'
  STORY_LIST_VIEW_CELL_IDENTIFIER = 'StoryListViewCell'

  attr_reader :stories

  def viewDidLoad
    super

    @stories = []
    tableView.delegate = self
    tableView.dataSource = self

    # Register a default class for all table cells so they can easily be reused later
    tableView.registerClass( UITableViewCell, forCellReuseIdentifier: STORY_LIST_VIEW_CELL_IDENTIFIER )

    # Add pull-to-refresh to the table, it's useful for the customer and a must have for the BDD/TDD tests
    pull_to_refresh = UIRefreshControl.alloc.init
    pull_to_refresh.addTarget( self, action: :pull_to_reload, forControlEvents: UIControlEventValueChanged )
    self.refreshControl = pull_to_refresh

    # Additional setup purely for spec-testing
    if RUBYMOTION_ENV == 'test'
      tableView.accessibilityLabel = 'Story List'
    end
  end

  def viewWillAppear( animated )
    super
    reload_stories
  end

  ## UITableViewDataSource

  def tableView( table, numberOfRowsInSection: section )
    @stories.size
  end

  def tableView( table, cellForRowAtIndexPath: path )
    # @type [UITableViewCell] cell
    cell = table.dequeueReusableCellWithIdentifier( STORY_LIST_VIEW_CELL_IDENTIFIER )
    cell.textLabel.text = @stories[path.row]['meta']['set_name']
    cell
  end

  ## Custom methods

  # Force reloading of the cached story data - this will also cause a table refresh.
  def reload_stories
    @stories = load_available_stories
    tableView.reloadData
  end

  # Separate method for pull-to-refresh so the refreshControl is only activated when required.
  def pull_to_reload
    self.refreshControl.beginRefreshing
    reload_stories
    self.refreshControl.endRefreshing
  end

  private
  # Check the available stories in the Applications NSDocumentDirectory
  def load_available_stories
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

    # fetch a list of all files and directories inside STORY_ROOT and load their JSON
    res = []
    Dir.glob( File.join( @@STORY_ROOT.fileSystemRepresentation, '*.babbo' ) ).each do |bundle_path|
      # skip all uninteresting entries
      next unless File.directory?( bundle_path )
      next unless File.extname( bundle_path ) == '.babbo'

      main_json = File.join( bundle_path, 'SMIL', 'control.json' )
      next unless File.exists?( main_json )

      raw = NSData.dataWithContentsOfFile( main_json, options: NSDataReadingMappedIfSafe, error: error_ptr)
      if raw.nil?
        NSLog( "Error while trying to read #{File.basename( main_json )}: #{error_ptr[0].localizedDescription}" )
      else
        data = NSJSONSerialization.JSONObjectWithData( raw, options: NSJSONReadingMutableLeaves, error: error_ptr)
        if data.nil?
          NSLog( "Error while trying to parse #{File.basename( main__json )}: #{error_ptr[0].localizedDescription}" )
        else
          res << data
        end
      end
    end
    # simple way to get a sortable number from the timestamp
    res.sort_by { |x| x['meta']['timestamp'] }
  end
end
