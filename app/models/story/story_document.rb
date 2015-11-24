# The Story module contains all classes dealing with parsing, validation
# and internal representation of story definitions (control.yml / control.json)
module Story
  # A thin wrapper around a documents root structure.
  # This class encapsulates all the metadata as well as header information.
  # The document body can be accessessed using the {#body} property.
  class Document
    include Story::AttributeValidationMixin

    validation_scope :document
    validation_scope :head
    validation_scope :meta

    # attributes parsed from :head
    attr_reader :data_language, :data_language_version, :template_id
    # attributes parsed from :meta
    attr_reader :document_id, :dataset_id, :branch_creator_id,
                :creator_impressum, :branch_name, :editor_id,
                :set_name, :thumbnail, :screenshot, :description,
                :status, :modified_conveyable, :timestamp, :body

    # Initialize a new Document instance
    def initialize
      @document_id = -1
      @set_name    = 'undefined'
      @branch_name = 'undefined'
      @valid       = false
    end

    # Check if this document is valid.
    # A freshly created document is always invalid an can only become
    # valid once it's {#load} method was successfully called.
    def valid?
      @valid
    end

    # Load the document attributes from the +Hash+ in +description+.
    #
    # All attributes will be validated, type converted and
    # - where appropriate and required - replaced with default values.
    #
    # @param [Hash] description A +Hash+ containing the initial values
    #   for this documents properties.
    # @return [Boolean] true if the document was initialized successfully.
    #   false if the attributes where invalid or the document was already
    #   initialized by calling +load+ before.
    def load( description )
      return false if valid?

      validate_attributes(description, :document) do |desc|
        validate_attributes(desc[:head], :head) do |head|

          @data_language         = head[:data_language]
          @data_language_version = head[:data_language_version]
          @template_id           = head[:template_id]

          unless @data_language == 'tuluh_smil'
            @validation_errors << "Unsupported data_language: '#{@data_language}'"
          end

          unless @data_language_version == '1.0'
            @validation_errors << "Unsupported data_language_version: '#{@data_language_version}'"
          end
        end

        # No sense in continuing if we know the validation failed.
        break unless validation_errors.empty?

        validate_attributes(desc[:meta], :meta) do |meta|

          @document_id         = meta[:dokument_id]
          @dataset_id          = meta[:dataset_id]
          @branch_name         = meta[:branch_name]
          @branch_creator_id   = meta[:branch_creator_id]
          @creator_impressum   = meta[:creator_impressum]
          @editor_id           = meta[:editor_id]
          @set_name            = meta[:set_name]
          @thumbnail           = meta[:thumbnail]
          @screenshot          = meta[:screenshot]
          @description         = meta[:description]
          @status              = meta[:status]
          @modified_conveyable = meta[:modified_conveyable]
          @timestamp           = meta[:timestamp]

          unless [:template, :V1, :V2].include? @status
            @validation_errors << "Unsupported status: '#{@status}'"
          end
        end

        break unless validation_errors.empty?

        body = Story::Body.new

        if body.load(desc[:body]) == false
          @validation_errors += body.validation_errors.map { |err| "In body: #{err}" }
          body = nil
        else
          @body = body
        end
      end

      @valid = true if validation_errors.empty?
      valid?
    end
  end
end

