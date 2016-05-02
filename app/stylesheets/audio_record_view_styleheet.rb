class AudioRecordViewStylesheet < ApplicationStylesheet
  def setup
  end

  def root (st)
    st.frame = {x: 0, y: 0, w: device.screen_width, h: device.screen_height}
    st.background_color = rmq.color.clear
  end

  def background_layer (st)
    st.frame = {x: 0, y: 0, w: device.screen_width, h: device.screen_height}
    st.background_color = rmq.color.light_gray
    st.alpha = 0.25
  end

  def cancel_button (st)
    st.frame = {fr: 0.05 * device.screen_width, t: 0.05 * device.screen_height, w: 0.1 * device.screen_height, h: 0.1 * device.screen_height}
    st.background_image = rmq.image.resource('babbo_icons/close_normal.png')
    st.clips_to_bounds = true
    st.corner_radius = 0.1 * device.screen_height / 2
    st.border_color = rmq.color.white
    st.border_width = 2
    st.background_color = rmq.color.babbo_orange
  end

  def ok_button (st)
    st.frame = {l: 0.65 * device.screen_width,fb: 0.05 * device.screen_height, w: 0.1 * device.screen_height, h: 0.1 * device.screen_height}
    st.background_image = rmq.image.resource('icons/ic_save_white.png')
    st.clips_to_bounds = true
    st.corner_radius = 0.1 * device.screen_height / 2
    st.border_color = rmq.color.white
    st.border_width = 2
    st.background_color = rmq.color.babbo_orange
  end

  def repeat_button (st)
    st.frame = {l: 0.85 * device.screen_width, fb: 0.05 * device.screen_height, w: 0.1 * device.screen_height, h: 0.1 * device.screen_height}
    st.background_image = rmq.image.resource('babbo_icons/restart_normal.png')
    st.clips_to_bounds = true
    st.corner_radius = 0.1 * device.screen_height / 2
    st.border_color = rmq.color.white
    st.border_width = 2
    st.background_color = rmq.color.babbo_orange
  end

  def record_button (st)
    st.frame = {l: 0.75 * device.screen_width, fb: 0.05 * device.screen_height, w: 0.1 * device.screen_height, h: 0.1 * device.screen_height}
    st.background_image = rmq.image.resource('babbo_icons/record_normal.png')
    st.clips_to_bounds = true
    st.corner_radius = 0.1 * device.screen_height / 2
    st.border_color = rmq.color.white
    st.border_width = 2
    st.background_color = rmq.color.babbo_orange
  end

  def play_button (st)
    st.frame = {l: 0.75 * device.screen_width, fb: 0.05 * device.screen_height, w: 0.1 * device.screen_height, h: 0.1 * device.screen_height}
    st.background_image = rmq.image.resource('babbo_icons/play_normal.png')
    st.clips_to_bounds = true
    st.corner_radius = 0.1 * device.screen_height / 2
    st.border_color = rmq.color.white
    st.border_width = 2
    st.background_color = rmq.color.babbo_orange
  end

  def stop_button (st)
    st.frame = {l: 0.75 * device.screen_width, fb: 0.05 * device.screen_height, w: 0.1 * device.screen_height, h: 0.1 * device.screen_height}
    st.background_image = rmq.image.resource('babbo_icons/stop_normal.png')
    st.clips_to_bounds = true
    st.corner_radius = 0.1 * device.screen_height / 2
    st.border_color = rmq.color.white
    st.border_width = 2
    st.background_color = rmq.color.babbo_orange
  end
end

