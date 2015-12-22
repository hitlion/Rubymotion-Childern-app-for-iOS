class SmartphoneTabbarView < UIView

  include TabbarModule

  def init_with_frame(frame, delegate: delegate)
    self.initWithFrame(frame)

    init_view_with_delegate(delegate)

    build_view

    self
  end

  def init_view_with_delegate(delegate)
    @pos_x_button_1     = 0.25
    @pos_x_button_2     = 0.475
    @pos_x_button_3     = 0.70

    @element_size       = 48
    @icon_size          = 24

    @delegate           = delegate

    @init = true
  end


end