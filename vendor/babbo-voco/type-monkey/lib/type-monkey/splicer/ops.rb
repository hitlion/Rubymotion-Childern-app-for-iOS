unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/splicer/ops/value-op'
  require 'type-monkey/splicer/ops/logic-op'
  require 'type-monkey/splicer/ops/true-op'
end

module TypeMonkey
  module Splicer
    module Ops
      # Default exception class used by all Ops classes.
      class Error < StandardError; end
    end
  end
end

