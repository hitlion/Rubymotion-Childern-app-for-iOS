class BabboBackend
  class << self
    attr_accessor :instance

    # Return the shared +BabboBackend+ instance.
    def get

      BabboBackend.instance ||= BabboBackend.new
    end
  end

  attr_reader :identifier, :identifier_data, :url_session, :identifier_url, :thumbnail_url, :screenshots_url

  def initialize

    @url_session      ||= NSURLSession.sessionWithConfiguration(NSURLSessionConfiguration.defaultSessionConfiguration)
    @identifier_url   ||= 'http://h2561319.stratoserver.net/store-assets/'
    @screenshots_url  ||= 'http://h2561319.stratoserver.net/store-assets/gallery/'
    @thumbnail_url    ||= 'http://h2561319.stratoserver.net/store-assets/teaser/'

    load_story_identifier
  end

  public
  # Request the identifier for all available stories. If the list is already loaded,
  # send the notification with the request source and the identifier. Else collect the
  # identifier from the backend an send then the notification
  def request_story_identifier
    if(@identifier)
      NSNotificationCenter.defaultCenter.postNotificationName('BackendUpdateIdentifier',
                                                              object:nil,
                                                              userInfo: {
                                                                  :identifier => @identifier
                                                              })
    else
      load_story_identifier
    end
  end

  # Request the thumbnail url for an given identifier.
  # After the request send a notification with the sender identity
  # and the thumbnails URL
  def request_thumbnail_url_for_identifier(identifier, sender: sender)
    id = get_id_for_identifier(identifier)
    return nil unless id

    begin
      task = @url_session.dataTaskWithURL(NSURL.URLWithString(@thumbnail_url + id.to_s), completionHandler: lambda {|data, response, error|
        if(error)
          NSLog ("Error requesting %@ : %@", @thumbnail_url, error.localizedDescription)
        else
          if response.statusCode == 200
            url = JSON.load(NSString.alloc.initWithData(data, encoding: NSUTF8StringEncoding)).first['field_teaser']

            NSNotificationCenter.defaultCenter.postNotificationName('BackendThumbnailURLReceived',
                                                                    object:nil,
                                                                    userInfo: {
                                                                        :sender => sender,
                                                                        :url => url
                                                                    })
          else
            NSLog ("Bad http response from %@, status code was %@", @thumbnail_url, response.statusCode)
          end
        end
      })
      task.resume
    rescue
      NSLog ('Error: HTTP request failed with url: %@ (loading screenshot urls)', @thumbnail_url)
    end
  end

  # Request the screenshots url's for an given identifier.
  # After the request send a notification with the sender identity
  # and an array with the screenshots URL's
  def request_screenshots_urls_for_identifier(identifier, sender: sender)
    id = get_id_for_identifier(identifier)
    return nil unless id

    begin
      task = @url_session.dataTaskWithURL(NSURL.URLWithString(@screenshots_url + id.to_s), completionHandler: lambda {|data, response, error|
        if(error)
          NSLog ("Error requesting %@ : %@", @screenshots_url, error.localizedDescription)
        else
          if response.statusCode == 200
            urls = JSON.load(NSString.alloc.initWithData(data, encoding: NSUTF8StringEncoding)).first['field_game_gallery'].split(',')

            NSNotificationCenter.defaultCenter.postNotificationName('BackendScreenshotURLReceived',
                                                                    object:nil,
                                                                    userInfo: {
                                                                        :sender => sender,
                                                                        :url => urls
                                                                    })
          else
            NSLog ("Bad http response from %@, status code was %@", @screenshots_url, response.statusCode)
          end
        end
      })
      task.resume
    rescue
      NSLog ('Error: HTTP request failed with url: %@ (loading screenshot urls)', @screenshots_url)
    end
  end

  # Request the create date for a story with an given identifier.
  # After the request send a notification with the sender's identity
  # and the date as string
  def request_timestamp_for_identifier(identifier, sender: sender)
    return nil unless @identifier_data

    id = get_id_for_identifier(identifier)
    return nil unless id

    data = @identifier_data.find{|data| data["nid"] == id.to_s}
    NSNotificationCenter.defaultCenter.postNotificationName('BackendDateReceived',
                                                            object:nil,
                                                            userInfo: {
                                                                :sender => sender,
                                                                :date => data["created"]
                                                            })
  end

  private
  # Request the store data from the backend server
  # and save the data in @identifier_data.
  # The data contains the identifier and an unique id for each story,
  # additional maybe later the release/update date
  def load_story_identifier
    @story_identifier_requested ||= false
    return if @story_identifier_requested

    begin
      @story_identifier_requested = true
      task = @url_session.dataTaskWithURL(NSURL.URLWithString(@identifier_url), completionHandler: lambda {|data, response, error|
        if(error)
          NSLog ("Error requesting %@ : %@", @identifier_url, error.localizedDescription)
        else
          if response.statusCode == 200
            NSLog ("Response is ok, update story identifer", response.statusCode )

            @identifier_data = JSON.load(NSString.alloc.initWithData(data, encoding: NSUTF8StringEncoding))

            @identifier = nil
            @identifier = []

            @identifier_data.each do |data|
              @identifier << data['field_store_id']
            end

            NSLog ('Backend sending notification about new identifiers')
            NSNotificationCenter.defaultCenter.postNotificationName('BackendUpdateIdentifier',
                                                                    object:nil,
                                                                    userInfo: {
                                                                        :identifier => @identifier
                                                                    })
          else
            NSLog ("Bad http response from %@, status code was %@", @identifier_url, response.statusCode)
          end
        end

        @story_identifier_requested = false
      })
      task.resume
    rescue
      NSLog ('Error: HTTP request failed with url http://h2561319.stratoserver.net/store-assets/ (loading identifier)')
      @story_identifier_requested = false
    end
  end

  # get the id (nid field) from the @identifier_data hash
  # return if there is no such data available
  def get_id_for_identifier(identifier)
    load_story_identifier if @identifier_data.nil?
    return nil if @identifier_data.nil?
    return nil if identifier.nil? || identifier == ''

    data = @identifier_data.find{|data| data['field_store_id'] == identifier }
    return nil unless data
    return data['nid']
  end
end

