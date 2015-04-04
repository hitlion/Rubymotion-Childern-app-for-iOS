class StoryListScreen
  def canBecomeFirstResponder
    true
  end

  def on_appear
    becomeFirstResponder
  end

  def will_disappear
    resignFirstResponder
  end

  def motionEnded( motion, withEvent: _ )
    super
    reload_stories if motion == UIEventSubtypeMotionShake
  end
end
