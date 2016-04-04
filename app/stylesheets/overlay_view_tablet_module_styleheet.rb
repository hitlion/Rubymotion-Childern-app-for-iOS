class OverlayViewTabletModuleStylesheet < ApplicationStylesheet
  def setup
  end

  def root (st)
    st.frame = {x: 0, y: 0, w: device.screen_width, h: device.screen_height}
    st.background_color = rmq.color.clear
    st.corner_radius = 0
  end

  def grey_layer (st)
    st.frame = {x: 0, y: 0, w: device.screen_width, h: device.screen_height}
    st.alpha = 0.5
    st.background_color = rmq.color.black
  end

  def image_box (st)

  end

  def title_label (st)

  end

  def left_button (st)

  end

  def right_button (st)

  end

  def background_layer( st )
    st.frame = {t: 0.1 * device.screen_height, l: 0.2 * device.screen_width, fr: 0.2 * device.screen_width, fb: 0.1 * device.screen_height}
    st.background_color = rmq.color.white
    st.corner_radius = 12.5
    st.border_width = 5
    st.border_color = rmq.color.babbo_orange
  end

  def status_label (st)
    st.frame = {t: 0.05 * device.screen_height, l: 10, fr: 10, h: 0.2 * device.screen_height}
  end

  def progress_view (st)
    st.frame = {bp: 0.05 * device.screen_height, l: 10, fr: 10, h: 0.2 * device.screen_height}
  end

end

