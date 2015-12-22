class TabletNavbarView < UIView


  include NavbarModule

  def init_with_frame(frame, titleText: titleText, delegate: delegate)
    self.initWithFrame(frame)

    init_navbar_with_delegate(delegate, titleText: titleText)

    build_view

    self
  end

end