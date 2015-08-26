class StoryLoggerStylesheet < ApplicationStylesheet
  def setup
  end

  def root( st )
    st.frame = :full
    st.alpha = 0.75
    st.tint_color = rmq.color.white
    st.background_color = rmq.color.black
  end

  def switch_mode_button( st )
    st.frame = {l: 5, fb: 5, w: 200, h: 20}
    st.unshift = 'Console'
    st.unshift = 'JavaScript'
    st.content_horizontal_alignment = UIControlContentHorizontalAlignmentCenter
    st.view.selectedSegmentIndex = 0
  end

  def dismiss_button( st )
    st.frame = {fr: 5, fb: 5, w: 50, h: 20}
    st.font  = rmq.font.font_with_name('Menlo', 20)
    st.text  = '⏏'
    st.color = rmq.color.white
    st.color_highlighted = rmq.color.red
    st.content_horizontal_alignment = UIControlContentHorizontalAlignmentCenter
  end
  def scroll_lock_switch( st )
    st.frame = {lop: 25, fb: 20, w: 30, h: 10}
    st.on    = true
    st.view.transform = CGAffineTransformMakeScale(0.5, 0.5)
  end

  def scroll_lock_label( st )
    st.frame = {lop: 5, fb: 5, w: 50, h: 20}
    st.font  = rmq.font.font_with_name('Menlo', 10)
    st.text  = 'scroll:'
    st.color = rmq.color.babbo_orange
  end

  def tranparent_touch_switch_switch( st )
    st.frame = {lop: 20, fb: 20, w: 30, h: 10}
    st.on    = false
    st.view.transform = CGAffineTransformMakeScale(0.5, 0.5)
  end

  def tranparent_touch_switch_label( st )
    st.frame = {lop: 5, fb: 5, w: 50, h: 20}
    st.font = rmq.font.font_with_name('Menlo', 10)
    st.text = 'touch:'
    st.color = rmq.color.babbo_orange
  end

  def log_messages_view( st )
    st.frame = {l: 5, fr: 5, t: 2, fb: 30}
    st.font  = rmq.font.font_with_name('Menlo', 10)
    st.color = rmq.color.white
    st.tint_color = rmq.color.white
    st.background_color = rmq.color.clear
    st.editable = false
    st.selectable = true
    st.scroll_enabled = true
  end 
end

