module Babbo
  # A single level inside a .babbo document
  class Level
    attr_reader :id, :screens, :path

    # Initialize the model instance from the parsed JSON data.
    # @param data [Hash] The parsed JSON data
    # @param parent [String] The path specification up to the parent object.
    def initialize( data, parent=nil )
      @id = data['level_id'].to_i
      @path = "#{parent || ''}:level[#{@id}]"
      @screens = ( data['screens'] || [] ).map { |screen| Babbo::Screen.new( screen, @path ) }
    end

    # Return a hash of objects and paths starting at this model instance.
    # @returns [Hash<String,Object>] A hash for all paths beneath this element.
    def paths()
      paths = { @path => self }
      @screens.each { |screen| paths.merge!( screen.paths ) }
      paths
    end
  end
end

