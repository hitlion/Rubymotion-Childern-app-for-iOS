module JavaScript
  # A wrapper around an instance of +SKScene+
  class ScreenProxy
    include JavaScript::BridgeMixin
    include JavaScript::Common

    javascript_export :b_b_v_j_s_bridged_object
    javascript_export :b_b_v_j_s_bridged_object_screen

    # Setup a new +ScreenProxy+ with a weak reference to +node+.
    #
    # @param [SKScene] node The scene node to wrap.
    def initialize( node )
      @node = WeakRef.new(node)
    end

    # @return [Fixnum] The wrapped nodes +scren_id+.
    def screen_id
      @node.screen_id
    end

    # @private
    # Switch to a different screen.
    #
    # @param [String] target The scene path to the target screen.
    def exit_to( target )
      Dispatch::Queue.main.async do
        # FIXME: I think this works by accident..
        story_player_screen = rmq.screen
        story_player_screen.show_scene(target) unless story_player_screen.nil?
      end
    end

    # @private
    # Exit from the current story and return to the story list
    def exit_story
      JavaScript::Runtime::send_event(':body', :at_end, async: false)

      # FIXME: I think this works by accident..
      story_player_screen = rmq.screen
      story_player_screen.close unless story_player_screen.nil?
    end
  end
end

