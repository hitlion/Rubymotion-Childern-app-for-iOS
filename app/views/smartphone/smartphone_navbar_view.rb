class SmartphoneNavbarView < UIView

  include NavbarModule

  def init_with_frame(frame, titleText: titleText, delegate: delegate)
    self.initWithFrame(frame)

    init_view_with_delegate(delegate, titleText: titleText)

    build_view

    self
  end

  def init_view_with_delegate(delegate, titleText: titleText )
    @pos_x_back_button  = 0.00
    @pos_x_label        = 0.085
    @pos_x_button_1     = 0.7
    @pos_x_button_2     = 0.8
    @pos_x_button_3     = 0.9
    @pos_x_searchbar    = 0.425

    @element_size       = 48
    @icon_size          = 24

    @label_width        = 0.4
    @searchbar_width    = 0.25

    @title_text         = titleText
    @delegate           = delegate

    @init = true
  end
end