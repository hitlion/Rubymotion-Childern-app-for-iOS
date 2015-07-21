# The main list of all available story bundles on the device.
class StoryListScreen < PM::TableScreen
  title 'Babbo Voco'
  refreshable
  longpressable

  # @return [Array<Hash>] An +Array+ containing one +Hash+ for each loaded story bundle.
  attr_accessor :stories
  def on_load
    @layout = StoryListLayout.new( root: self.view )
    @layout.build

    @stories = StoryStore.shared_store.reload
  end

  def on_refresh
    reload_stories
  end

  def table_data
    [{
      cells: @stories.map do |story|
        {
          title: story.set_name,
          action: :story_selected,
          long_press_action: :edit_story,
          arguments: story,
          image: story.thumbnail || { image: 'file_warning' }
        }
      end
    }]
  end

  def reload_stories
    @stories = StoryStore.shared_store.reload
    stop_refreshing
    update_table_data
  end

  def story_selected( story )
    open_modal StoryPlayerScreen.new( story: story, nav_bar: false )
  end

  def edit_story( story )
    open_modal StoryEditorScreen.new( story: story, nav_bar: true,  nav_controller: AutoRotatingNavigationController )
  end

  # force portrait orientation
  def supportedInterfaceOrientations()
    UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown
  end

  def preferredInterfaceOrientationForPresentation()
    UIInterfaceOrientationPortrait
  end

  def shouldAutorotate()
    true
  end

end

