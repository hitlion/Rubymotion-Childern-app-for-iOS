class StoryEditorMoveObjectViewStylesheet < ApplicationStylesheet
  def setup
  end

  def root( st )
    st.frame = {x: 0, y: 0, w: device.screen_width, h: device.screen_height}
    st.tint_color = rmq.color.black
    st.background_color = rmq.color.clear
  end

  def top_line (st)
    st.frame = {t:0, l:0, w: device.screen_width, h: 5}
    st.background_color = rmq.color.babbo_orange
  end

  def left_line (st)
    st.frame = {t:0, l:0, w: 5, h: device.screen_height}
    st.background_color = rmq.color.babbo_orange
  end

  def right_line (st)
    st.frame = {t:0, fr:0, w: 5, h: device.screen_height}
    st.background_color = rmq.color.babbo_orange
  end

  def bottom_line (st)
    st.frame = {fb:0, l:0, w: device.screen_width, h: 5}
    st.background_color = rmq.color.babbo_orange
  end

  def background_layer( st )
    st.frame = {t: 5, l: 5, fr: 5, fb: 5}
    st.background_color = rmq.color.black
    st.alpha = 0.5
  end

  def choose_root (st)
    st.frame = {x: 0, y: device.screen_height - 0.2 * device.screen_height, w: 0.2 * device.screen_width, h: 0.2 * device.screen_height}
    st.alpha = 1.0
    st.tint_color = rmq.color.black
    st.background_color = rmq.color.babbo_orange
    st.corner_radius = 12.5
  end

  def choose_background (st)
    st.frame = {t: 5, l: 5, fr: 5, fb: 5}
    st.background_color = rmq.color.white
    st.corner_radius = 12.5
  end

  def accept_button (st)
    st.frame = {t:  0.02 * device.screen_height, l: 10, fr: 10, h: 0.075 * device.screen_height}
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:bold), TTUtil.get_font_size(:medium))
    st.text  = 'Bestätigen'
    st.color = rmq.color.white
    st.background_color = rmq.color.light_gray
    st.corner_radius = 12.5
  end

  def deny_button (st)
    st.frame = {bp: 0.01 * device.screen_height, l: 10, fr: 10, h: 0.075 * device.screen_height}
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:bold), TTUtil.get_font_size(:medium))
    st.text  = 'Abbrechen'
    st.color = rmq.color.white
    st.background_color = rmq.color.light_gray
    st.corner_radius = 12.5
  end

  def movable_object_dummy (st)
    st.frame = {l:0, t:0, w:1, h:1}
    st.background_color = rmq.color.white
  end
end

