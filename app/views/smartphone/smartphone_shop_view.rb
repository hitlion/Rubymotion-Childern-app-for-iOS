class SmartphoneShopView < UIScrollView

  include ShopViewModule

  def init_with_frame(frame, delegate: delegate)
    self.initWithFrame(frame)

    init_view_with_delegate(delegate)

    build_view

    self
  end

  def init_view_with_delegate(delegate)
    @top_view_height    = 0.75
    @bottom_view_height = 0.75

    @delegate           = delegate

    @init = true
  end
end