module Babbo
  module JSBridge
    class Generic
      def initialize( story_node )
        #PM::logger.debug( "creating new #{self.class} -> #{story_node}" )
        @node = story_node
      end

      def name()
        @node.path
      end
    end
  end
end

