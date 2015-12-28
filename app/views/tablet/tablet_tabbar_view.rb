class TabletTabbarView < UIView

  include TabbarModule

  def init_with_frame(frame, delegate: delegate)
    self.initWithFrame(frame)

    init_view_with_delegate(delegate)

    build_view

    self
  end
end