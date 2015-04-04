unless RUBY_ENGINE == 'rubymotion'
  require 'type-monkey/splicer/ops'
end

module TypeMonkey
  module Splicer
    module Ops
      # Always-true dummy operation
      class TrueOp
        # @return [TrueClass]
        def eval( object )
          true
        end
      end
    end
  end
end

