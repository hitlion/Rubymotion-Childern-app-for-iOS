module JavaScript
  # A wrapper around an instance of {#Scene::PictureNode}
  class PictureProxy
    include JavaScript::BridgeMixin
    include JavaScript::Common

    javascript_export :b_b_v_j_s_bridged_object
    javascript_export :b_b_v_j_s_bridged_object_picture

    # Setup a new +PictureProxy+ with a weak reference to +node+
    # 
    # @param [Scene::PictureNode] node The picture node to wrap.
    def initialize( node )
      @node = WeakRef.new(node)
    end
  end
end

