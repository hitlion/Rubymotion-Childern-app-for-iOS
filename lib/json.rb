# Wrapper around NSJSONSerialization providing a more ruby-like interface.
# The supported calls mirror what the +YAML+ class does for YAMLKit.
class JSON
  # @private
  READING_OPTIONS = NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves

  class << self

    # Return a +Object+ from a given JSON string.
    #
    # @param [String] string A string containing JSON data
    # @return [Object] An +Object+ representing the JSON data from +string+
    #   or +nil+.
    def load( string )
      bytes = string.dataUsingEncoding(NSUTF8StringEncoding)
      error = Pointer.new(:object)
      obj   = NSJSONSerialization.JSONObjectWithData(bytes,
                                                     options: READING_OPTIONS,
                                                     error: error)

      unless obj.nil?
        return obj
      end

      mp "JSON.load: #{error[0].localizedDescription}", force_color: :red
      nil
    end

    # Returns a +String+ with JSON data from a given +Object+
    #
    # @param [Object] object The object from which to generate the JSON string.
    # @return [String] A JSON string or +nil+ if an error occurs.
    def dump( object )
      error = Pointer.new(:object)
      data  = NSJSONSerialization.dataWithJSONObject(object,
                                                     options: 0,
                                                     error: error)

      unless data.nil?
        return NSString.alloc.initWithData(data, encoding: NSUTF8StringEncoding)
      end

      mp "JSON.dump: #{error[0].localizedDescription}", force_color: :red
      nil
    end
  end
end

class NSObject
  # Returns a +String+ with this objects JSON representation.
  # @return [String] A JSON string or +nil+ if an error occurs.
  def to_json
    JSON.dump(self)
  end
end

