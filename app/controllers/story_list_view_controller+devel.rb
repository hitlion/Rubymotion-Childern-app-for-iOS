# Development-only extensions to StoryListViewController
class StoryListViewController

  # become the first responder if nothing else is selected
  def viewDidAppear( animated )
    super
    becomeFirstResponder
  end

  def canBecomeFirstResponder
    true
  end

  # trigger a reload if a device shake is detected (until Apple fixes table-drag in UIAutomation.. *sigh*)
  def motionEnded( _, withEvent: event )
    if event.subtype == UIEventSubtypeMotionShake
      reload_stories
    end
  end
end
