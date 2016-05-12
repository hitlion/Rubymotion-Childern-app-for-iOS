class ScenePlayer < SKView
  def initWithFrame( frame )
    super( frame ).tap do
      on(:tap, fingers_required: 1) do |_, event|
        unless scene.nil?
          object = object_at_location(event.location)
          unless object.nil?
            JavaScript::Runtime.send_event(object.name, :on_click)
          end
        end
      end

      %w(up down left right).each do |direction|
        on("swipe_#{direction}".to_sym) do |_, event|
          unless scene.nil?
            object = object_at_location(event.location)
            unless object.nil?
              JavaScript::Runtime.send_event(object.name, :on_swipe)
            end
          end
        end
      end

      on(:pinch) { |_, _| rmq(:logger).map { |l| l.show } }
    end
  end

  private

  def object_at_location( location )
    point = scene.convertPointFromView(location)
    scene.nodeAtPoint(point)
  end
end

