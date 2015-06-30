module Babbo
  # Common error instance
  class Error < StandardError; end

  # Top level class representing a .babbo documents control.json
  class Document
    include Babbo::Actionable

    attr_reader :levels

    # Initialize the model instance from the parsed JSON data.
    # @param data [Hash] The parsed JSON data
    # @param bundle_path [String] The absolute path to the .babbo bundle
    #   on the device filesystem.
    def initialize( data, bundle_path )
      # this should already be checked by TypeMonkey but wth..
      # at least we assume the required fields *are present*
      unless data['head']['data_language'] == 'tuluh_smil' and
             data['head']['data_language_version'] == '1.0'
        raise Babbo::Error, "Invalid .babbo document (head data)"
      end

      @metadata = {
        :document_id => data['meta']['document_id'].to_i,
        :dataset_id  => data['meta']['dataset_id'].to_i,
        :branch_name => data['meta']['branch_creator_id'].to_s,
        :branch_creator_id => data['meta']['branch_creator_id'].to_i,
        :creator_impressum => data['meta']['creator_impressum'].to_s,
        :editor_id => data['meta']['editor_id'].to_i,
        :set_name  => data['meta']['set_name'].to_s,
        :thumbnail => data['meta']['thumbnail'].to_s,
        :status => data['meta']['status'].to_s,
        :modified_conveyable => data['meta']['modified_conveyable'] || false,
        :timestamp => data['meta']['timestamp']
      }

      @levels = ( data['body']['levels'] || [] ).map { |level| Babbo::Level.new( level ) }
      @bundle_path = bundle_path

      parse_slots( data['body']['body_slot'] || [] )
      parse_events( data['body']['body_event'] || {}, %w(at_load at_end) )
    end

    def document_id
      @metadata[:document_id].to_i
    end

    def dataset_id
      @metadata[:dataset_id].to_i
    end

    def branch_creator_id
      @metadata[:branch_creator_id].to_i
    end

    def creator_impressum
      @metadata[:creator_impressum]
    end

    def branch_name
      @metadata[:branch_name]
    end

    def editor_id
      @metadata[:editor_id].to_i
    end

    def set_name
      @metadata[:set_name]
    end

    def thumbnail
      bundled_resource( @metadata[:thumbnail], of_type: :picture )
    end

    def status
      @metadata[:status].to_s
    end

    def modified_conveyable
      @metadata[:modified_conveyable]
    end

    def timestamp
      @metadata[:timestamp]
    end

    def levels
      @levels
    end

    # Locate a concrete object instance given a path string.
    # @param path [String] A path notation :obj:obj:obj
    # @return [Object] The object instance mathing the path or nil.
    def object_for_path( path )
      # lazy build a map of all paths in the document
      @paths ||= begin
        paths = {}
        @levels.each { |level| paths.merge!( level.paths ) }
        paths
      end
      @paths[path]
    end

    # Load a resounce file (video, picture, audio) from the .babbo bundle
    # and return a suitable player or image instance.
    # @param name [String] the path to the resource, relative to the .json.
    # @param type [Enum] One of the resource types :video, :picture, :audio.
    # @return [Object] A player object suitable for the media type.
    def bundled_resource( name, of_type: type )
      return nil unless [ :video, :picture, :audio ].include? type

      # resource URIs should be relative to the SMIL directory (for now)
      unless name.start_with? '..'
        name = "../contents/#{name}"
      end

      resource_path = "#{@bundle_path}/SMIL/#{name}"
      resource_url  = NSURL.fileURLWithPath( resource_path )
      mp_d( "Attempting to load '#{name}' of type #{type}.." )
      if File.exists? resource_path
        case type
          when :video
            return AVPlayer.playerWithURL( resource_url )
          when :picture
            if File.extname( resource_path ).downcase == '.gif'
              # possibly animated, return the raw data
              return NSData.dataWithContentsOfFile( resource_path )
            else
              return UIImage.imageWithContentsOfFile( resource_path )
            end
          when :audio
            # FIXME: nil should really be an NSError**
            return AVAudioPlayer.alloc.initWithContentsOfURL( resource_url, error: nil )
        end
      else
        return nil
      end
    end

    # Create a SpriteKit scene from a given path.
    # The path should specify a single screen inside a level.
    # @param path [String] A path specification locating a singel screen.
    # @returns [SKScene] A sprite kit scene node.
    def create_scene( path )
      mp_l( "Creating SpriteKit Scene for #{path}" )
      screen = object_for_path( path )
      if screen.is_a? Babbo::Screen
        Babbo::SpriteBridge::SceneProxy.new( screen ).create_sknode( self )
      else
        nil
      end
    end
  end
end

