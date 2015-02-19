require 'jstype/types/basic_type'

# Some small additions to BasicType to ease spec tests
class BasicType
  class << self
    # Reset the type registry and with it prevent any re-registration errors
    # between tests.
    def reset!
      BasicType.type_registry.select! { |_,v| v.class == SimpleType || v.class == CompoundType }
    end
  end
end
