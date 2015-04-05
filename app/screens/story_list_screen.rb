# The main list of all available story bundles on the device.
class StoryListScreen < PM::TableScreen
  title 'Story List'
  refreshable

  # @return [Array<Hash>] An +Array+ containing one +Hash+ for each loaded story bundle.
  attr_accessor :stories

  def on_load
    @layout = StoryListLayout.new( root: self.view )
    @layout.build

    @stories = []
    reload_stories
  end

  def on_refresh
    reload_stories
  end

  def table_data
    [{
      cells: @stories.map do |story|
        {
          title: story.set_name
        }
      end
    }]
  end

  def reload_stories
    @stories = StoryStore.shared_store.reload
    stop_refreshing
    update_table_data
  end
end

