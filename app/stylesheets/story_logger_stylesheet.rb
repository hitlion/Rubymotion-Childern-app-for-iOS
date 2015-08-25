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
    st.frame = {l: 5, fb: 5, w: 100, h: 20}
    st.font  = rmq.font.font_with_name('Menlo', 10)
    st.text  = '[JavaScript]'
    st.color = rmq.color.white
    st.color_highlighted = rmq.color.red
    st.content_horizontal_alignment = UIControlContentHorizontalAlignmentLeft
  end

  def dismiss_button( st )
    st.frame = {fr: 5, fb: 5, w: 50, h: 20}
    st.font  = rmq.font.font_with_name('Menlo', 10)
    st.text  = '[ X ]'
    st.color = rmq.color.white
    st.color_highlighted = rmq.color.red
    st.content_horizontal_alignment = UIControlContentHorizontalAlignmentCenter
  end

  def scroll_lock_button( st )
    st.frame = {lop: 5, fb: 5, w: 100, h: 20}
    st.font  = rmq.font.font_with_name('Menlo', 10)
    st.text  = '[scroll: true]'
    st.color = rmq.color.white
    st.color_highlighted = rmq.color.red
    st.content_horizontal_alignment = UIControlContentHorizontalAlignmentCenter
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

