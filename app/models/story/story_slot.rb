module Story
  class Slot
    attr_reader :name, :action, :variables

    # Initialize a new Slot instance.
    #
    # If the list passed in +variables+ contains invalid or
    # incomplete variables they will be parsed as name/content 'undefined'.
    #
    # @param [String] name A name identifying this slot.
    # @param [String] action The designated JavaScript code for this slot
    # @param [Array<Hash<Symbol,String>>] variables A list of
    #   { :name => 'name', :content => 'content' } hashes.
    def initialize(name, action, variables)
      @name      = name
      @action    = action
      @variables = Hash[variables.map { |var| [var[:name] || 'undef',
                                               var[:content] || 'undef'] }]
    end
  end
end

