# extend {CGPoint} to support marshalling
class CGPoint
  class << self
    # @private
    def _load( args )
      new(*args.split(':').map { |a| a.to_f })
    end
  end

  # @private
  def _dump( level )
    [ self.x, self.y ].join(':')
  end
end
