module Babbo
  class Slot
    attr_reader :name, :action, :variables, :busy
    attr_accessor :active

    # initialize a new slot instance
    # @param data [Hash] The parsed JSON for this slot
    def initialize( data )
      @name = data['name']
      @action = data['action']
      # TODO: this is a dummy-store as it is now.
      # ...   variable content and objects are resolved on
      # ...   slot execution.
      @variables = ( data['variables'] || {} ).map do |var|
        { 
          :name    => var['name'],
          :content => var['content']
        }
      end
      @busy = NSLock.alloc.init
    end
  end
end

