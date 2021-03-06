class SceneEditor < SKView
  def initWithFrame( frame )
    super( frame ).tap do
      on(:tap, fingers_required: 1) do |_, event|
        unless scene.nil?
          object = object_at_location(event.location)
          lp "Editor: screen tapped at #{event.location}"
          if object
            NSNotificationCenter.defaultCenter.postNotificationName('on_editor_tap',
                                                               object: nil,
                                                               userInfo: {
                                                                 :location => event.location,
                                                                 :object => object.name
                                                               })
          else
            NSNotificationCenter.defaultCenter.postNotificationName('on_editor_tap',
                                                               object: nil,
                                                               userInfo: {
                                                                 :location => event.location
                                                               })
          end
        end
      end

      %w(up down left right).each do |direction|
        on("swipe_#{direction}".to_sym) do |sender, event|
          unless scene.nil?
            NSNotificationCenter.defaultCenter.postNotificationName('on_editor_swipe',
                                                               object: nil,
                                                               userInfo: {
                                                                 :sender => sender,
                                                                 :location => event.location,
                                                                 :direction => direction.to_sym
                                                               })
          end
        end
      end

      on(:pinch) { |_, _| rmq(:logger).map { |l| l.show } }
    end
  end

  def node_for_path(path)
    return if(path.nil?)
    path = path.gsub(/([\[\]])/, '\\\\\\1')
    res = scene.childNodeWithName("//#{path}")

    return res.parent  if(path.start_with? 'CN:')

    res
  end

  private

  def object_at_location( location )
    point = scene.convertPointFromView(location)
    scene.nodeAtPoint(point)
  end
end

