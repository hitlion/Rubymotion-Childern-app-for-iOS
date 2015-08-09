class StandardAppearance
  def self.apply( window )
    # common tinting / design colors
    rmq.color.add_named( :babbo_orange, '#f9bc34' )

    # global default styles
    Dispatch.once do
      UIWindow.appearance.tap do |o|
        o.tintColor = rmq.color.babbo_orange
      end

      UINavigationBar.appearance.tap do |o|
        o.barTintColor = rmq.color.babbo_orange
        o.setTintColor( rmq.color.white )
        o.setTitleTextAttributes( {
          UITextAttributeTextColor => rmq.color.white
        } )
      end
    end
  end
end

