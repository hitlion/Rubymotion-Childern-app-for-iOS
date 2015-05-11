module Babbo
  module SpriteBridge
    class SceneProxy < Proxy
      def initialize( babbo_screen )
        @screen = babbo_screen
        @objects = []
      end

      def create_sknode( document )
        @node ||= begin
          ##scene_size = CGSizeMake(max(UIScreen.mainScreen.bounds.size.width,
          ##                            UIScreen.mainScreen.bounds.size.height),
          ##                        min(UIScreen.mainScreen.bounds.size.width,
          ##                            UIScreen.mainScreen.bounds.size.height))

          scene_size = calc_size( CGSizeMake( 1.0, 1.0 ) )

          PM::logger.info( "scene { #{scene_size.width}, #{scene_size.height} }")
          scene = Babbo::SpriteBridge::Scene.alloc.initWithSize( scene_size )
          scene.document = document

          @screen.objects.each do |object|
            #@objects << Babbo::SpriteBridge::ObjectProxy.new( object )
            bridge_object = Babbo::SpriteBridge::ObjectProxy.new( object )
            scene.addChild( bridge_object.create_sknode( scene ) )
          end
          @screen.scene_node = scene
          scene
        end
      end
    end
  end
end

