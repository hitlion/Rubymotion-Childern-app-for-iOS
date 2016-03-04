module JavaScript
  # A wrapper around an instance of {#Scene::TextNode}
  class TextProxy
    include JavaScript::BridgeMixin
    include JavaScript::Common

    javascript_export :b_b_v_j_s_bridged_object
    javascript_export :b_b_v_j_s_bridged_object_text

    # Setup a new +TextProxy+ with a weak reference to +node+
    # 
    # @param [Scene::PictureNode] node The picture node to wrap.
    def initialize( node )
      @node = WeakRef.new(node)
    end

    def color(args)
      args = Hash.symbolicate(args)
      if args[:red] && args[:blue] && args[:green] && args[:alpha]
        red = args[:red].to_f
        green = args[:green].to_f
        blue = args[:blue].to_f
        alpha = args[:alpha].to_f
        color = UIColor.colorWithRed(red, green: green, blue: blue, alpha: alpha)
        node.fontColor = color
      end
    end

    def text(args)
      args = Hash.symbolicate(args)
      if args[:text] && args[:size]
        node.fontSize = args[:size].to_i
        node.text = args[:text]
      end
    end

  end
end

