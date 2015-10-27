class StoryListScreen < PM::TableScreen
  title 'Babbo Voco'
  stylesheet StoryListStylesheet

  refreshable

  # Initial view setup
  def on_load
    @story_bundles = []
    reload_bundles
    set_nav_bar_button :right, title: "Kids", action: :go_to_kids_menu
  end

  # Reload the table data
  def on_refresh
    reload_bundles
    stop_refreshing
    update_table_data
  end

  # Return the structured table data for ProMotion
  # @todo: Handle branch data
  def table_data
    [{
      cells: @story_bundles.map do |bundle|
        if bundle.valid?
          cell_data_for_valid_bundle(bundle)
        else
          cell_data_for_invalid_bundle(bundle)
        end
      end
    }]
  end

  private

  # Reload the cached +StoryBundle+'s based on the contents
  # of the 'Bundles' directory on disk.
  #
  # @todo: Handle branch data
  def reload_bundles
    @story_bundles = StoryBundle.bundles
  end

  # Create a ProMotion compatible cell data +Hash+ from the given +StoryBundle+
  # This method asumes that the bundle was loaded successfully.
  #
  # @param [StoryBundle] bundle The +StoryBundle+ that should be displayed in
  #   the table cell.
  # @return [Hash] A +Hash+ formated for use in ProMotions #table_data.
  def cell_data_for_valid_bundle(bundle)
    thumbnail   = UIImage.imageWithData(bundle.asset_data(bundle.document.thumbnail))
    thumbnail ||= 'placeholder/file_image'

    title_text    = bundle.document.set_name || bundle.document.branch_name

    detail_button = UIButton.buttonWithType(UIButtonTypeDetailDisclosure)
    detail_button.on(:tap) do
      app.alert(title: title_text,
                message: bundle.document.creator_impressum)
    end

    {
      title: title_text,

      image: { image: thumbnail, radius: 5 },

      editing_style: :delete,
      accessory: { view: detail_button },

      action: :play_story,
      arguments: { bundle: bundle }
    }
  end

  # Create a ProMotion compatible cell data +Hash+ from the given +StoryBundle+
  # This method asumes that the bundle had load errors and will only use data
  # that is available in this case.
  #
  # @param [StoryBundle] bundle The +StoryBundle+ that should be displayed in
  #   the table cell.
  # @return [Hash] A +Hash+ formated for use in ProMotions #table_data.
  def cell_data_for_invalid_bundle(bundle)
    detail_button = UIButton.buttonWithType(UIButtonTypeDetailDisclosure)
    detail_button.setImage(image.resource('exclamation'), forState: UIControlStateNormal)
    detail_button.setImage(image.resource('exclamation'), forState: UIControlStateHighlighted)
    detail_button.setTintColor(rmq.color.red)

    detail_button.on(:tap) do
      open LoadErrorsScreen.new(nav_bar: true,
                                nav_controller: AutoRotatingNavigationController,
                                title: File.basename(bundle.path),
                                load_errors: bundle.load_errors)
    end

    {
      title: File.basename(bundle.path),
      image: { image: 'placeholder/file_information' },
      style: { text_color: rmq.color.red },

      editing_style: :delete,
      accessory: { view: detail_button },

      action: :show_error_alert
    }
  end

  public

  # Start the +StoryPlayerScreen+ displaying a given +StoryBundle+
  def play_story( args )
    return if args[:bundle].nil?
    return unless args[:bundle].valid?

    open_modal StoryPlayerScreen.new(nav_bar: false,
                                     nav_controller: AutoRotatingNavigationController,
                                     story_bundle: args[:bundle])
  end

  def show_error_alert
    app.alert(title: 'Entschuldigung',
              message: 'Diese Story enthält Fehler und kann nicht angezeigt werden.')
  end

  def go_to_kids_menu
    StartScreen.next_screen= :kids_menu

    rmq.screen.close(to_screen: :root)
  end

end

