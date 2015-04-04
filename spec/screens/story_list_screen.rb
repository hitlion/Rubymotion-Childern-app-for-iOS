describe StoryListScreen do
  tests StoryListScreen

  alias :screen :controller
  def screen
    @screen ||= StoryListScreen.new
  end

  it 'has a list of all available stories' do
    screen.instance_variable_defined?( '@stories' ).should.equal true
    screen.instance_variable_get( '@stories' ).class.should.equal Array
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
      screen.reload_stories
      screen.stories.size.should.be == 2
    end

    it 'sorts the list entries using their "timestamp" property' do
      last = '1970-01-01t00:00:01+00:00'

      screen.reload_stories
      screen.stories.each do |story|
        last.compare( story['meta']['timestamp'] ).should >= NSOrderedAscending
        last = story['meta']['timestamp']
      end
    end

    it 'has one table row for each entry in the list' do
      # force a reload
      screen.on_load

      screen.stories.size.should > 0
      screen.table_data.first[:cells].length.should.be == screen.stories.size
    end

    it 'has the textLabel of each row table set to the "set_name" of the matching list entry' do
      screen.stories.each_with_index do |story, index|
        screen.tableView.visibleCells[index].textLabel.text.should.equal( story['meta']['set_name'] )
      end
    end
  end
end
