module Babbo
  module JSBridge
    class Screen < Babbo::JSBridge::Generic
      def exit_to( path )
        Dispatch::Queue.main.sync do
          notify = NSNotificationCenter.defaultCenter
          # freeze any running video / audio etc.
          @node.scene_node.enumerateChildNodesWithName( '//*', usingBlock: lambda { |node, stop|
            if node.is_a? SKVideoNode
              node.pause
              notify.removeObserver( StoryPlayerScreen.active_instance.scene,
                                      name: AVPlayerItemDidPlayToEndTimeNotification,
                                    object: node.userData[:player].currentItem )
            end
            node.userData = {}
          })


          # FIXME: this is probably the uggliest, baddest way to get to the StoryPlayerScreen possible..
          story_player = UIApplication.sharedApplication.keyWindow.rootViewController.visibleViewController
          story_player.show_scene( path, true ) if story_player.is_a? StoryPlayerScreen
        end
      end

      def exit_story()
        Dispatch::Queue.main.sync do
          notify = NSNotificationCenter.defaultCenter
          # freeze any running video / audio etc.
          @node.scene_node.enumerateChildNodesWithName( '//*', usingBlock: lambda { |node, stop|
            if node.is_a? SKVideoNode
              node.pause
              notify.removeObserver( StoryPlayerScreen.active_instance.scene,
                                      name: AVPlayerItemDidPlayToEndTimeNotification,
                                    object: node.userData[:player].currentItem )
            end

            node.userData = {}
          })

          # FIXME: this is probably the uggliest, baddest way to get to the StoryPlayerScreen possible..
          story_player = UIApplication.sharedApplication.keyWindow.rootViewController.visibleViewController
          story_player.close if story_player.is_a? StoryPlayerScreen
        end
      end
    end
  end
end

