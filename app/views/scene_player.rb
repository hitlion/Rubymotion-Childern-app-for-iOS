class ScenePlayer < SKView
  def initWithFrame( frame )
    super( frame ).tap do
      on(:tap) do |_, event|
        return if scene.nil?

        point = scene.convertPointFromView(event.location)
        object = scene.nodeAtPoint(point)

        unless object.nil?
          JavaScript::Runtime.send_event(object.name, :on_click)
        end
      end
    end
  end
end

