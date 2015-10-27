class StartScreen < PM::Screen

  class << self
    attr_accessor :next_screen
  end

  title "Start Screen"
  stylesheet StartScreenStyleSheet

  def on_load
    set_nav_bar_button :right, title: "Kids", action: :go_to_kids
    set_nav_bar_button :left, title: "Parent", action: :go_to_parent

    append(UIImageView, :logo)
  end

  def go_to_kids
    open_modal KidsScreen.new(nav_bar: false,
                          nav_controller: AutoRotatingNavigationController)
  end

  def go_to_parent
    open_modal StoryListScreen.new(nav_bar: true,
        nav_controller: AutoRotatingNavigationController)
  end

  def go_to_age_verification
    open_modal AgeVerificationScreen.new(nav_bar: false,
                                   nav_controller: AutoRotatingNavigationController)
  end

  def on_appear(args={})

    if(StartScreen.next_screen.nil?)
      go_to_kids
    end

    if StartScreen.next_screen == :parent_menu
      go_to_parent
    end

    if StartScreen.next_screen == :kids_menu
      go_to_kids
    end

    if StartScreen.next_screen == :age_verification_screen
      go_to_age_verification
    end

  end

end
