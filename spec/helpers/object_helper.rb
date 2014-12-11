class Object
  # Add support to change the global RUBYMOTION_ENV constant to {Object}.
  # Note that this is generally not a good thing to do but sadly the ApplicationDelegate spec currently requires it.
  # @param [String] value The new value for ::RUBYMOTION_ENV.
  # @return [String] The value of ::RUBYMOTION_ENV before changing it
  # @return [Nil] If ::RUBYMOTION_ENV wasn't defined.
  def self.spec_fake_motion_env( value )
    if defined? :RUBYMOTION_ENV
      old = RUBYMOTION_ENV
      send( :remove_const, :RUBYMOTION_ENV )
    end

    const_set( :RUBYMOTION_ENV, value )
    old ||= nil
    old
  end
end
