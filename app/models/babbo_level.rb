module Babbo
  class Level
    attr_reader :id, :screens

    def initialize( data )
      @id = data['level_id'].to_i
      @screens = ( data['screens'] || [] ).map { |screen| Babbo::Screen.new( screen ) }
    end
  end
end

