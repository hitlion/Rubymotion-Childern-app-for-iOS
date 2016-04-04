module OverlayViewModuleNew

  attr_reader :story

  def initWithFrame( frame, type: type )
   self.initWithFrame(frame).tap do

      if(device.ipad?)
        rmq(self).stylesheet = OverlayViewTabletModuleStylesheet
      end

      rmq(self).apply_style(:root)

      append(UIView, :grey_layer)
      append(UIView, :background_layer)
    end
  end

  def hide
    self.hidden = true
  end

  def show
    self.hidden = false
  end
end