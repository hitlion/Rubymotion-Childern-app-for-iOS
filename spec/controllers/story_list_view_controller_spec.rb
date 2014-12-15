describe 'The Story-List View Controller' do
  tests StoryListViewController

  before do
    # force loading of the view
    controller.view
  end

  it 'is the delegate for it\'s table view.' do
    controller.tableView.delegate.should == controller
  end

  it 'is the data source for it\'s table view.' do
    controller.tableView.dataSource.should == controller
  end

  it 'has a list of all available stories' do
    controller.instance_variable_defined?( '@stories' ).should.equal true
    controller.instance_variable_get( '@stories' ).class.should.equal Array
  end

  context 'When there are stories available it' do
    before do
      fixture_install( fixture_host_path( 'features', 'data', 'list_all_json_files' ), 'Bundles', :NSDocumentDirectory )
    end

    after do
      fixture_remove( 'Bundles', :NSDocumentDirectory )
    end

    it 'has one entry for each story in it\'s list' do
      # TODO: it would be nice to detect the count at runtime
      controller.reload_stories
      controller.stories.size.should == 2
    end

    it 'sorts the list entries using their "timestamp" property' do
      last = '1970-01-01t00:00:01+00:00'

      controller.reload_stories
      controller.stories.each do |story|
        last.compare( story['meta']['timestamp'] ).should >= NSOrderedAscending
        last = story['meta']['timestamp']
      end
    end

    it 'has one table row for each entry in the list' do
      # force a reload
      shake()
      #drag 'Story List', :from => :top

      controller.stories.size.should > 0
      controller.tableView( controller.tableView, numberOfRowsInSection: 1 ).should == controller.stories.size
    end

    it 'has the textLabel of each row table set to the "set_name" of the matching list entry' do
      controller.stories.each_with_index do |story, index|
        controller.tableView.visibleCells[index].textLabel.text.should.equal( story['meta']['set_name'] )
      end
    end
  end
end
