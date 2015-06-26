module Babbo
  module SpriteBridge
    class SceneProxy < Proxy
      def initialize( babbo_screen )
        @screen = babbo_screen
      end

      def create_sknode( document )
        scene_size = calc_size( CGSizeMake( 1.0, 1.0 ) )

        mp_l( "scene { #{scene_size.width}, #{scene_size.height}, '#{@screen.path}' }")
        scene = Babbo::SpriteBridge::Scene.alloc.initWithSize( scene_size )
        scene.document = document
        scene.name     = @screen.path

        @screen.objects.each do |object|
          bridge_object = Babbo::SpriteBridge::ObjectProxy.new( object )
          scene.addChild( bridge_object.create_sknode( scene ) )
        end
        scene
      end
    end
  end
end

