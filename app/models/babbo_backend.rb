class BabboBackend
  class << self
    attr_accessor :instance

    # Return the shared +BabboBackend+ instance.
    def get
      BabboBackend.instance ||= BabboBackend.new
    end
  end

  attr_reader :identifier, :identifier_data

  def initialize
    load_story_identifier
  end

  public
  # Request the identifier for all available stories. If the list is already loaded,
  # send the notification with the request source and the identifier. Else collect the
  # identifier from the backend an send then the notificatiob
  def request_story_identifier(sender)
    if(@identifier)
      NSNotificationCenter.defaultCenter.postNotificationName('BackendUpdateIdentifier',
                                                              object:nil,
                                                              userInfo: {
                                                                  :sender => sender,
                                                                  :identifier => @identifier
                                                              })
    else
      load_story_identifier do
        NSNotificationCenter.defaultCenter.postNotificationName('BackendUpdateIdentifier',
                                                                object:nil,
                                                                userInfo: {
                                                                    :sender => sender,
                                                                    :identifier => @identifier
                                                                })
      end
    end
  end

  # Request the thumbnail url for an given identifier.
  # After the request send a notification with the sender
  # and the thumbnails URL
  def request_thumbnail_url_for_identifier(identifier, sender: sender)
    id = get_id_for_identifier(identifier)
    BubbleWrap::HTTP.get('http://h2561319.stratoserver.net/store-assets/teaser/' + id.to_s) do |response|
      if(response.body != [] && response.status_description)
        data = JSON.load(response.body.to_s)
        url = data.first['field_teaser']
        url.split(',')
      else
        url = nil
      end

      NSNotificationCenter.defaultCenter.postNotificationName('BackendThumbnailURLReceived',
                                                              object:nil,
                                                              userInfo: {
                                                                  :sender => sender,
                                                                  :url => url
                                                              })
    end
  end

  # Request the screenshots url's for an given identifier.
  # After the request send a notification with the sender
  # and an array with the screenshots URL's
  def request_screenshots_urls_for_identifier(identifier, sender: sender)
    id = get_id_for_identifier(identifier)
    BubbleWrap::HTTP.get('http://h2561319.stratoserver.net/store-assets/gallery/' + id.to_s) do |response|

      if(response.body != [] && response.status_description)
        data = JSON.load(response.body.to_s)
        lp data
        url = data.first['field_game_gallery']
      else
        url = nil
      end

      NSNotificationCenter.defaultCenter.postNotificationName('BackendScreenshotURLReceived',
                                                              object:nil,
                                                              userInfo: {
                                                                  :sender => sender,
                                                                  :url => url
                                                              })
    end
  end

  private
  # Request the store data from the backend server
  # and save the data in @identifier_data.
  # The data contains the identifier and an unique id for each story,
  # additional maybe later the release/update date
  # call the given block after the request
  def load_story_identifier(&block)
    BubbleWrap::HTTP.get('http://h2561319.stratoserver.net/store-assets/') do |response|
      lp response
      if(response.body != [] && response.status_description)
        data = JSON.load(response.body.to_s)
        lp data
        @identifier_data = data
        @identifier = []
        @identifier_data.each do |data|
          @identifier << data['field_store_id']
        end

        block.call(true) if block
      else
        block.call(false) if block
      end
    end
  end

  # get the id (nid field) from the @identifier_data hash
  # return if there is no such data available
  def get_id_for_identifier(identifier)
    load_story_identifier if @identifier_data.nil?
    return nil if @identifier_data.nil?
    return nil if identifier.nil? || identifier == ''

    data = @identifier_data.find{|data| data['field_store_id'] == identifier }
    return data['nid']
  end
end

