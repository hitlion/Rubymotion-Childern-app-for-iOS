class StandardAppearance
  def self.apply( window )
    # common tinting / design colors
    rmq.color.add_named(:babbo_orange, '#f9bc34')

    rmq.color.add_named(:term_gray   , '#bebebe')
    rmq.color.add_named(:term_red    , '#fc2b33')
    rmq.color.add_named(:term_green  , '#b0cc71')
    rmq.color.add_named(:term_yellow , '#fdb14b')
    rmq.color.add_named(:term_blue   , '#82c1d9')
    rmq.color.add_named(:term_magenta, '#dc99cd')
    rmq.color.add_named(:term_cyan   , '#89cfc4')
    rmq.color.add_named(:term_white  , '#e8e8e8')

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

