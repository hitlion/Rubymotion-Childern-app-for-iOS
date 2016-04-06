class ServerBackend
  class << self
    attr_accessor :instance

    # Return the shared +ServerBackend+ instance.
    def get
      ServerBackend.instance ||= ServerBackend.new
    end
  end

  def initialize
    @story_data = {}
    @tips_data = {}

    @backend_dir = File.join(Dir.system_path(:documents), 'Backend')

    @stories_path = File.join(@backend_dir, 'stories')
    @story_data_path = File.join(@stories_path, 'story_data')
    @screenshots_path = File.join(@stories_path, 'screenshots')

    @tips_path = File.join(@backend_dir, 'tips_and_tricks')
    @tips_image_path = File.join(@tips_path, 'images')
    @tips_data_path = File.join(@tips_path, 'data')

    config_path = File.join(@story_data_path, 'story_*.yml')
    lp "Backend: reading config files from #{config_path}... "
    Dir.glob(config_path).each do |story_def|
      data = YAML.load(File.read(story_def))
      data = Hash.symbolicate(data) unless data.nil?
      next unless validate_story_definition(data)

      @story_data["#{data[:document_id]}_#{data[:dataset_id]}"] = data
    end

    tips_path = File.join(@tips_data_path, 'tip_*.yml')
    lp "Backend: reading tips data from #{tips_path}... "
    Dir.glob(tips_path).each_with_index do |tips_def, index|
      data = YAML.load(File.read(tips_def))
      data = Hash.symbolicate(data) unless data.nil?
      next unless validate_tips_definition(data)

      @tips_data[index] = data
    end
  end

  # Return the description for a given tip.
  # @param [Int] tip The number for a tip
  def description_for_tip(tip)
    return @tips_data[tip][:description]
  end

  # Return the number of available tips
  def number_of_tips
    return @tips_data.count
  end

  # Return the image for a given tip.
  # @param [Int] tip The number for a tip
  def image_for_tip(tip)
    res = nil
    image_path = File.join(@tips_image_path, @tips_data[tip][:image])

    if File.exists? image_path
      res = UIImage.imageWithContentsOfFile(image_path)
    end
    res
  end

  # Return the header for a given tip.
  # @param [Int] tip The number for a tip
  def header_for_tip(tip)
    return @tips_data[tip][:header]
  end

  # Return the description for a given story.
  #
  # @param [StoryBundle] story The story bundle for which a
  #   description should be retrieved.
  # @return [String] The story description or +nil+ if no
  #   description could be retreived.
  def description_for_story( story )
    return nil if story.nil?
    return nil unless story.valid?

    add_story(story)
    @story_data[story_uuid(story)][:description]
  end

  # Return an +Array+ of +UIImage+ objects
  # representing the screenshots for a given story.
  #
  # @param [StoryBundle] story The story bundle for which the
  #   screenshots should be retrieved.
  # @return [Array<UIImage>] An +Array+ of +UIImage+ objects
  #   with each member representing one screenshot or +nil+ if
  #   any error occurs.
  def screenshots_for_story( story )
    return nil if story.nil?
    return nil unless story.valid?

    add_story(story)

    res = []
    @story_data[story_uuid(story)][:screenshots].each do |path|
      image_path = File.join(@screenshots_path, path)
      next unless File.exists? image_path

      res << UIImage.imageWithContentsOfFile(image_path)
    end
    res
  end

  # Return the star rating for a given story.
  #
  # @param [StoryBundle] story The story bundle for which the
  #   rating should be retrieved.
  # @return [Float] A star rating raning for 0.0 to 5.0.
  #   If no rating could be retrieved 0.0 is returned.
  def rating_for_story( story )
    return nil if story.nil?
    return nil unless story.valid?

    add_story(story)
    @story_data[story_uuid(story)][:rating]
  end

  # Set the description for a given story.
  # This will set and store the description for the given
  # story in the backend.
  #
  # @param [StoryBundle] story The story for which to set
  #   the description.
  # @param [String] desc The description to store for this
  #   story.
  # @return [String] On success the description is returned.
  #   if any error occurs the result will be +nil+.
  def set_description_for_story( story, desc )
    return nil if story.nil?
    return nil unless story.valid?

    add_story(story) unless @story_data.has_key? story_uuid(story)
    @story_data[story_uuid(story)][:description] = desc.to_s

    return nil unless update_backend_files
    desc
  end

  # Set the screenshots array for a given story.
  # This will set and store the screenshots for the given
  # story in the backend.
  #
  # @param [StoryBundle] story The story for which to set
  #   the screenshots.
  # @param [Array<UIImage>] images An +Array+ of +UIImage+
  #   objects holding the screenshots
  # @return [Array<UIImage>] On success the screenshots array
  #   is returned.
  def set_screenshots_for_story( story, images )
    return nil if story.nil?
    return nil unless story.valid?

    if @story_data.has_key? story_uuid(story)
      # remove old files first
      @story_data[story_uuid(story)][:screenshots].each do |path|
        File.unlink(File.join(@screenshots_path, path))
      end
    else
      add_story(story)
    end

    # store each image as PNG called 'screenshot_X.X_Y.png'
    # where X.X is the document.dataset ID and Y is the screenshot index.
    image_names = []
    images.each_with_index do |img, n|
      image_path = File.join(@screenshots_path, "screenshot_#{story_uuid(story)}_#{n}.png")
      open(image_path, 'w') do |io|
        io.write(UIImagePNGRepresentation(img))
        image_names << File.basename(image_path)
      end
    end

    @story_data[story_uuid(story)][:screenshots] = image_names
    return nil unless update_backend_files
    images
  end

  # Set the rating for a given story.
  # This will set and store the rating for the given
  # story in the backnde.
  #
  # @param [StoryBundle] story The story for which to set
  #   the rating.
  # @param [Float] rating A 5-star rating in the range 0.0-5.0.
  # @return [Float] On success the rating will be returned.
  def set_rating_for_story( story, rating )
    return nil if story.nil?
    return nil unless story.valid?

    rating = 0.0 if rating < 0.0
    rating = 5.0 if rating > 5.0

    add_story(story) unless @story_data.has_key? story_uuid(story)
    @story_data[story_uuid(story)][:rating] = rating.to_f

    return nil unless update_backend_files
    rating.to_f
  end

  def get_thumbnail_for_identifier(identifier)
    return 'http://bit.ly/18iMhwc'
  end

  def get_screenshots_for_identifier(identifier)
    return ['http://bit.ly/18iMhwc', 'http://bit.ly/18iMhwc']
  end

  def get_rating_for_identifier(identifier)
    return 5.0
  end

  def get_identifiers
    identifier = ['de.tuluh_tec.babbo_voco.erbse','de.tuluh_tec.babbo_voco.memory','de.tuluh_tec.babbo_voco.zahlenspiel', 'de.tuluh_tec.babbo_voco.test_story']
    return identifier
  end

  private

  # Check if the loaded story data contains all required keys.
  # @param [Hash] data A +Hash+ containing the story data definition
  # @return [Boolean] true or false depending if the data is valid.
  def validate_story_definition( data )
    return false if data.nil?

    [:document_id, :description, :rating, :screenshots].each do |key|
      return false unless data.has_key? key
    end
    true
  end

  # Check if the loaded tips data contains all required keys.
  # @param [Hash] data A +Hash+ containing the story data definition
  # @return [Boolean] true or false depending if the data is valid.
  def validate_tips_definition( data )
    return false if data.nil?

    [:header, :description, :image].each do |key|
      return false unless data.has_key? key
    end
    true
  end

  # Add an entry in @story_data representing the given story
  #
  # @param [StoryBundle] story The story to be added.
  def add_story( story )
    return if @story_data.has_key? story_uuid(story)

    if ! story.nil? && story.valid?
      @story_data[story_uuid(story)] = {
        :document_id => story.document.document_id,
        :dataset_id => story.document.dataset_id,
        :rating => 1.0,
        :screenshots => [],
        :description => "Es wurde leider keine Beschreibung für die Story gefunden."
      }
    end
  end

  # Update the on-disk version of @story_data.
  # Basically all this does is create a YAML file for each of
  # key in @story_data.
  # @return [Boolean] true an success, false if any error occured.
  def update_backend_files
    @story_data.each do |key, data|
      storage_path = File.join(@story_data_path, "story_#{key}.yml")
      open(storage_path, 'w') do |io|
        io.write(YAML.dump(data))
      end
    end
    true
  end

  # Return a unique ID for a given story.
  #
  # @param [StoryBundle] story The story for which to fetch the UUID.
  # @return [String] The unique ID as strong or +nil+ if an error occurs.
  def story_uuid( story )
    return nil if story.nil?
    return nil unless story.valid?

    return "#{story.document.document_id}_#{story.document.dataset_id}"
  end

end

