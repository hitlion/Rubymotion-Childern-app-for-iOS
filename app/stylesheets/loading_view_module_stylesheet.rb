class LoadingViewModuleStylesheet < ApplicationStylesheet
  def setup
  end

  def root( st )
    st.frame = {x: 0, y: 0, w: 0.55 * device.screen_width, h: 0.55 * device.screen_height}
    st.alpha = 1.0
    st.tint_color = rmq.color.black
    st.background_color = rmq.color.babbo_orange
    st.corner_radius = 12.5
  end

  def background_layer( st )
    st.frame = {t: 0.05 * device.screen_height, l: 5, fr: 5, fb: 0.05 * device.screen_height}
    st.background_color = rmq.color.white
    st.corner_radius = 12.5
  end

  def status_label (st)
    st.frame = {t: 0.05 * device.screen_height, l: 10, fr: 10, h: 0.2 * device.screen_height}
  end

  def progress_view (st)
    st.frame = {bp: 0.05 * device.screen_height, l: 10, fr: 10, h: 0.2 * device.screen_height}
  end

end

