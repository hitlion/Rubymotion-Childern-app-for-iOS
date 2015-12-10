class StartScreen < PM::Screen

  class << self
    attr_accessor :next_screen
    attr_accessor :next_story
    attr_accessor :last_screen
    attr_accessor :warmup_done
  end

  title "Start Screen"
  stylesheet StartScreenStyleSheet

  def on_load
    StartScreen.warmup_done ||= false

    set_nav_bar_button :right, title: "Kids", action: :go_to_kids
    set_nav_bar_button :left, title: "Parent", action: :go_to_parent

    append(UIImageView, :logo)
    append(UIProgressView, :load_progress).hide
  end

  def goto_kids
    open KidsScreen.new
  end

  def goto_parent
    if(device.ipad?)
      open TabletParentScreen.new
    else
      open SmartphoneParentScreen.new
    end
  end

  def goto_age_verification
    open AgeVerificationScreen.new
  end

  def start_story
    StartScreen.next_screen = StartScreen.last_screen
    open_modal StoryPlayerScreen.get(StartScreen.next_story)
  end

  def goto_story_list
    open StoryListScreen.new(nav_bar:true)
  end

  def goto_test
    open TestScreen.new
  end

  def goto_shop

  end

  def on_appear(args={})
    # perform asynchronous loading exactly *once*
    Dispatch.once do
      progress_callback = -> (total, progress) do
        if total > progress
          Dispatch::Queue.main.sync do
            rmq(:load_progress).show
            rmq(:load_progress).get.setProgress(progress.to_f / total.to_f, animated: true)
          end
        end
        if total == progress
          Dispatch::Queue.main.async do
            StartScreen.warmup_done = true
            rmq(:load_progress).hide
            dispatch
          end
        end
      end

      # background loading with progress status
      StoryBundle.bundles(async: true, callback: progress_callback)
    end

    # dispatch only after StoryBundle was loaded at least once
    dispatch if StartScreen.warmup_done
  end

  def dispatch
    if(StartScreen.next_screen.nil?)
      goto_parent
    elsif StartScreen.next_screen == :parent_menu
      goto_parent
    elsif StartScreen.next_screen == :kids_menu
      goto_kids
    elsif StartScreen.next_screen == :age_verification_screen
      goto_age_verification
    elsif StartScreen.next_screen == :story_player
      start_story
    elsif StartScreen.next_screen == :shop_menu
      goto_shop
    elsif StartScreen.next_screen == :story_list
      goto_story_list
    end
  end

end
