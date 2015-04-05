module Babbo
  class Slot
    attr_reader :name, :action, :variables

    def initialize( data )
      @name = data['name']
      @action = data['action']
      # TODO: this is a dummy-store as it is now.
      # ...   variables nedd their conten object resolved
      # ...   and probably should be real objects anyway..
      @variables = ( data['variables'] || {} ).map do |var|
        { 
          :name    => var['var_name'],
          :content => var['content']
        }
      end
    end
  end
end

