# Declare +names+ to be private module functions.
# @param [Array] names A list of names that should be converted to
#   private module functions.
# @todo Not sure I like how this polutes the global scope..
def private_module_function( *names )
    names.each do |name|
      module_function name
      private_class_method name
    end
end

