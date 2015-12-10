module JavaScript
  class Cache
    include JavaScript::BridgeMixin

    javascript_export :b_b_v_j_s_bridged_cache

    # Setup a new +Cache+
    def initialize
      @properties = {}
    end

    ## everything below is bridged to JavaScript

    # @private
    # Return a cache item or +nil+ if it was not set before.
    # @param [String] name The items name
    # @return [Object] Whatever the item was set to contain.
    def get( name )
      @properties.fetch(name.to_sym, nil)
    end

    # @private
    # Set a named cache item to a given value.
    # @param [String] name The items new name.
    # @param [Object] val The desired value.
    # @return [Object] Basically returns +val+
    def set( name, value: val )
      @properties[name.to_sym] = val
    end

    # @private
    # Propert getter returing all known item names
    # @return [Array<String>] All item names that where
    #   where created by a previous call to #set.
    def props
      @properties.keys.map { |k| k.to_s }
    end
  end
end

