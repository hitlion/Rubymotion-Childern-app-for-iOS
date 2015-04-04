module Boolean
  # just so TrueClass and FalseClass can be coaxed to respond
  # to .is_a? Boolean
end

class TrueClass
  include Boolean
end

class FalseClass
  include Boolean
end

