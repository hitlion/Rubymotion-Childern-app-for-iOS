module Babbo
  class Slot
    attr_reader :name, :action, :variables, :busy
    attr_accessor :active

    def initialize( data )
      @name = data['name']
      @action = data['action']
      # TODO: this is a dummy-store as it is now.
      # ...   variables nedd their conten object resolved
      # ...   and probably should be real objects anyway..
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

