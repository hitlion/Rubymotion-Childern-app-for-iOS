class StartScreen < PM::Screen

  class << self
    attr_accessor :next_screen
    attr_accessor :next_story
    attr_accessor :last_screen
    attr_accessor :warmup_done
    attr_reader   :animation_a, :animation_b
  end

  title "Start Screen"
  stylesheet StartScreenStyleSheet

  NamesAnimationA = ["animations/load_screen_babbo_animation_A0.png", "animations/load_screen_babbo_animation_A1.png",
                    "animations/load_screen_babbo_animation_A2.png", "animations/load_screen_babbo_animation_A3.png",
                    "animations/load_screen_babbo_animation_A4.png", "animations/load_screen_babbo_animation_A5.png",
                    "animations/load_screen_babbo_animation_A6.png"]
  NamesAnimationB = ["animations/load_screen_babbo_animation_B0.png", "animations/load_screen_babbo_animation_B1.png"]


  def on_load
    StartScreen.warmup_done ||= false

    set_nav_bar_button :right, title: "Kids", action: :go_to_kids
    set_nav_bar_button :left, title: "Parent", action: :go_to_parent

    append(UIImageView, :background)
    append(UIProgressView, :load_progress)

    @current_index = 0

    load_images

    build_animation
  end

  def load_images
    return if(!@animation_a.nil? && !@animation_b.nil?)

    @animation_a = []
    @animation_b = []

    NamesAnimationA.each do |name|
      @animation_a.addObject(UIImage.imageNamed(name))
    end

    NamesAnimationB.each do |name|
      @animation_b.addObject(UIImage.imageNamed(name))
    end
  end

  def build_animation

    @animation_frame = UIImageView.alloc.initWithFrame(CGRectMake(0.25 * self.frame.size.width, 0.25 * self.frame.size.height,
                                                                  0.3 * self.frame.size.width, 0.4 * self.frame.size.height))
    add @animation_frame

    animate_animation_a
  end

  def animate_animation_a
    duration = 0.1 * @animation_a.length
    @animation_frame.animationImages = @animation_a
    @animation_frame.animationDuration = duration
    @animation_frame.startAnimating
    self.performSelector("animate_animation_b", withObject: nil, afterDelay: duration)
  end

  def animate_animation_b
    @animation_frame.stopAnimating
    @animation_frame.animationImages = @animation_b
    @animation_frame.animationDuration = 0.1 * @animation_b.length
    @animation_frame.startAnimating
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

  def edit_story
    StartScreen.next_screen = StartScreen.last_screen
    open_modal StoryEditorScreen.get(StartScreen.next_story)
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
    #Dispatch.once do
    unless StartScreen.warmup_done
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
            CLSLog('Bundle preload done, dispatching')
            rmq(:load_progress).hide
            dispatch
          end
        end
      end

      # background loading with progress status
      CLSLog('Calling out for initial bundle pre-load')
      StoryBundle.bundles(async: true, callback: progress_callback)
    end

    # dispatch only after StoryBundle was loaded at least once
    dispatch if StartScreen.warmup_done
  end

  def dispatch
    case StartScreen.next_screen
      when :parent_menu
        goto_parent
      when :kids_menu
        goto_kids
      when :age_verification_screen
        goto_age_verification
      when :story_player
        start_story
      when :story_editor
        edit_story
      when :shop_menu
        goto_shop
      when :story_list
        goto_story_list
      else
        goto_parent
    end
  end

end
