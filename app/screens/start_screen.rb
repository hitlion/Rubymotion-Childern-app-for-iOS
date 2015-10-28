class StartScreen < PM::Screen

  class << self
    attr_accessor :next_screen
    attr_accessor :next_story
  end

  title "Start Screen"
  stylesheet StartScreenStyleSheet

  def on_load
    set_nav_bar_button :right, title: "Kids", action: :go_to_kids
    set_nav_bar_button :left, title: "Parent", action: :go_to_parent

    append(UIImageView, :logo)
  end

  def go_to_kids
    open KidsScreen.new
  end

  def go_to_parent
    open StoryListScreen.new(nav_bar: true)
  end

  def go_to_age_verification
    open AgeVerificationScreen.new
  end

  def start_story
    open_modal StoryPlayerScreen.new(nav_bar: false,
                                     story_bundle: StartScreen.next_story)
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

    if StartScreen.next_screen == :story_player
      start_story
    end

  end

end
