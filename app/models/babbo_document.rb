module Babbo
  # Top level class representing a .babbo documents control.json
  class Error < StandardError; end

  class Document
    include Babbo::Actionable

    attr_reader :levels

    def initialize( data )
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
      # TODO
      nil
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
  end
end

