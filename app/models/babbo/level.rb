module Babbo
  class Level
    attr_reader :id, :screens, :path

    def initialize( data, parent=nil )
      @id = data['level_id'].to_i
      @path = "#{parent || ''}:level[#{@id}]"
      @screens = ( data['screens'] || [] ).map { |screen| Babbo::Screen.new( screen, @path ) }
    end

    def paths()
      @paths ||= begin
        paths = { @path => self }
        @screens.each { |screen| paths.merge!( screen.paths ) }
        paths
      end
    end
  end
end

