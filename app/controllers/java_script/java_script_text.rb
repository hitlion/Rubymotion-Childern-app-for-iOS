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
      return unless node.weakref_alive?
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
      return unless node.weakref_alive?
      args = Hash.symbolicate(args)
      node.text = args[:text] if args[:text]
      node.fontSize = TTUtil.get_font_size(args[:size].intern) if args[:size]
      node.hidden = false
    end

  end
end

