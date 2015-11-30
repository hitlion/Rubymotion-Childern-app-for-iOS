class StartScreen < PM::Screen

  class << self
    attr_accessor :next_screen
    attr_accessor :next_story
    attr_accessor :last_screen
  end

  title "Start Screen"
  stylesheet StartScreenStyleSheet

  def on_load
    set_nav_bar_button :right, title: "Kids", action: :go_to_kids
    set_nav_bar_button :left, title: "Parent", action: :go_to_parent

    append(UIImageView, :logo)
  end

  def goto_kids
    open KidsScreen.new
  end

  def goto_parent
    open ParentScreen.new
  end

  def goto_age_verification
    open AgeVerificationScreen.new
  end

  def start_story
    StartScreen.next_screen = StartScreen.last_screen
    open_modal StoryPlayerScreen.get(StartScreen.next_story)
  end

  def goto_test
    open TestScreen.new
  end

  def goto_shop
    open StoryListScreen.new(nav_bar:true)
  end
  def on_appear(args={})

    if(StartScreen.next_screen.nil?)
      goto_shop
    end

    if StartScreen.next_screen == :parent_menu
      goto_parent
    end

    if StartScreen.next_screen == :kids_menu
      goto_kids
    end

    if StartScreen.next_screen == :age_verification_screen
      goto_age_verification
    end

    if StartScreen.next_screen == :story_player
      start_story
    end

    if StartScreen.next_screen == :shop_menu
      goto_shop
    end

  end

end
