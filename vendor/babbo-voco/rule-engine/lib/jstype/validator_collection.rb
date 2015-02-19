require 'jstype/object_validator' unless RUBY_ENGINE == 'rubymotion'

# A collection of #ObjectValidator instances used to verify a JSON document.
class ValidatorCollection
  attr_reader :title, :scopes, :result_type, :result_errors

  # Setup a new +ValidatorCollection+
  # @param [String] title The title of the validation scope contained within
  # @param [Array<ObjectValidator>] scopes An array with all validators available
  #   inside the scope.
  def initialize( title, scopes )
    @title = title
    @scopes = scopes
    @result_type = nil
    @result_errors = []
  end

  # Validate a parsed JSON document against the validation scope.
  # If there are multiple validators for the toplevel element they are tried
  # one after the other. If one returns +true+ the document is considered valid.
  # After validation the type which was found to be valid can be accessed using
  # the #ValidatorCollection.result_type property.
  # If the document didn't pass the validation the errors can be accessed using
  # the #ValidatorCollection.result_errors list.
  # It contains an array of the form [ 'type name', [ 'error', 'error', ...] ]
  # for each validator contained in the collection.
  # @param [Hash|Array] value The parsed JSON document data.
  # @return [TrueClass] if the document passed validation
  # @return [FalseClass] if the validation failed.
  def validate( value )
    @scopes.each do |scope|
      if scope.validate( value )
        @result_type   = scope.type.type_name
        @result_errors = []
        return true
      else
        @result_errors << [scope.type.type_name, scope.errors]
      end
    end
    @result_type = nil
    false
  end
end
