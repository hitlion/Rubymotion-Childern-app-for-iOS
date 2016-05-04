class StoryEditorChangeViewBoxStylesheet < ApplicationStylesheet
  def setup
  end

  def root (st)
    st.frame = {x: 0, w: device.screen_width, h: 0.25 * device.screen_height, t: 0.8 * device.screen_height}
    st.alpha = 1.0
    st.tint_color = rmq.color.black
    st.background_color = rmq.color.babbo_orange
    st.corner_radius = 25
  end

  def background (st)
    st.frame = {l: 5, fr:5, t:5, fb:5}
    st.background_color = rmq.color.white
    st.corner_radius = 25
  end

  def text_label (st)
    st.frame = {l: 0.35 * device.screen_width, t:0.025 * device.screen_height, w: 0.3 * device.screen_width, h: 0.2 * device.screen_height}
    device.ipad? ? st.font = rmq.font.pad_large : st.font = rmq.font.phone_large
    st.text  = 'Level wechseln'
    st.text_alignment = :center
  end

  def back_button (st)
    st.frame = {l: 0.15 * device.screen_width, t:0.025 * device.screen_height, w: 0.15 * device.screen_width, h: 0.2 * device.screen_height}
    st.background_image = rmq.image.resource('babbo_icons/left.png')
  end

  def next_button (st)
    st.frame = {l: 0.7 * device.screen_width, t:0.025 * device.screen_height, w: 0.15 * device.screen_width, h: 0.2 * device.screen_height}
    st.background_image = rmq.image.resource('babbo_icons/right.png')
  end

  def close_button (st)
    st.frame = {l: 0.9 * device.screen_width, t:0.015 * device.screen_height, w: 0.075 * device.screen_width, h: 0.1 * device.screen_height}
    st.background_image = rmq.image.resource('babbo_icons/close.png')
  end

end

