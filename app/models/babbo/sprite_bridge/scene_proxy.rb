module Babbo
  module SpriteBridge
    class SceneProxy < Proxy
      def initialize( babbo_screen )
        @screen = babbo_screen
      end

      def create_sknode( document, enable_editor = false )
        scene_size = calc_size( CGSizeMake( 1.0, 1.0 ) )

        mp_l( "scene { #{scene_size.width}, #{scene_size.height}, '#{@screen.path}' }")
        if enable_editor
          scene = Babbo::SpriteBridge::EditorScene.alloc.initWithSize( scene_size )
        else
          scene = Babbo::SpriteBridge::Scene.alloc.initWithSize( scene_size )
        end
        scene.document = document
        scene.name     = @screen.path

        @screen.objects.each do |object|
          bridge_object = Babbo::SpriteBridge::ObjectProxy.new( object )
          sknode = bridge_object.create_sknode( scene, enable_editor )
          unless sknode.nil?
            scene.addChild( sknode )
          end
        end
        scene
      end
    end
  end
end

