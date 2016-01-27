# extend {CGSize} to support marshalling
class CGSize
  class << self
    # @private
    def _load( args )
      new(*args.split(':').map { |a| a.to_f })
    end
  end

  # @private
  def _dump( level )
    [ self.width, self.height ].join(':')
  end
end
