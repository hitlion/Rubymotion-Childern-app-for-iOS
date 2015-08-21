class Hash
  # Return a new hash with all keys replaced by +Symbol+s.
  # This operation is performed recursively on all elements in the +Hash+
  # and will also iterate over +Array+ values to check for nested +Hash+es.
  #
  # @param [Hash] hash The hash to symbolicate
  # @return [Hash] A new hash with only +Symbol+s used as keys.
  def self.symbolicate( hash )
    hash.each_with_object({}) do |(k, v), g|
      g[k.to_sym] = (Hash === v) ? Hash.symbolicate(v)
                                 : ((Array === v) ? v.map { |e| (Hash === e) ? Hash.symbolicate(e) : e }
                                                  : v)
    end
  end

  # See Hash#symbolicate
  def symbolicate
    Hash.symbolicate(self)
  end
end

# @private
class NilClass
  # Return +nil+ if NilClass#symbolicate is called
  def symbolicate
    nil
  end
end

