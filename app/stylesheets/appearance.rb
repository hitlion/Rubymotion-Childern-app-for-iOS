class StandardAppearance
  def self.apply( window )
    # common tinting / design colors
    rmq.color.add_named(:babbo_orange, '#f9bc34')
    rmq.color.add_named(:babbo_bar_grey, '#f7f7f7')
    rmq.color.add_named(:babbo_line_grey,'#4d4d4d')


    # global default styles
    Dispatch.once do
      UIWindow.appearance.tap do |o|
        o.tintColor = rmq.color.babbo_orange
      end

      UINavigationBar.appearance.tap do |o|
        o.tintColor = rmq.color.white
        o.barTintColor = rmq.color.babbo_orange
        o.setTitleTextAttributes({
          UITextAttributeTextColor => rmq.color.white
        })
      end

      UIView.appearance.tap do |o|
        o.setTintColor(rmq.color.babbo_orange)
      end

    end
  end
end

