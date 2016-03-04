class StoryEditorChangeScreenBoxStylesheet < ApplicationStylesheet
  def setup
  end

  def root(st)
    st.frame = {x: 0, w: device.screen_width, h: 100, t: 600}
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

  def level_box (st)
    st.frame = {l: 120, t:10, w: 120, h: 100}
  end

  def screen_box (st)
    st.frame = {rop: 120, t:10, w: 120, h: 100}
  end

  def cancel_button( st )
    st.frame = {rop: 80, t:30, w: 150, h: 40}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_REGULAR, 25)
    st.text  = 'Abbrechen'
    st.color = rmq.color.white
    st.background_color = rmq.color.light_gray
    st.corner_radius = 12.5
  end

  def ok_button( st )
    st.frame = {rop: 80, t:30, w: 150, h: 40}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_REGULAR, 25)
    st.text  = 'OK'
    st.color = rmq.color.white
    st.background_color = rmq.color.light_gray
    st.corner_radius = 12.5
  end

  def level_label (st)
    st.frame = {l: 0, t:0, w: 120, h: 40}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_REGULAR, 22)
    st.text  = 'Level:'
    st.text_alignment = :center
  end

  def level_stepper (st)
    st.frame = {l: 0, bp:10, w: 120, h: 40}
    st.view.minimumValue = 1
    st.view.maximumValue = 100
    st.view.stepValue    = 1
    st.centered = false
  end

  def screen_label (st)
    st.frame = {l: 0, t:0, w: 120, h: 40}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_REGULAR, 22)
    st.text  = 'Screen:'
    st.text_alignment = :center
  end

  def screen_stepper (st)
    st.frame = {t: 100, l: 0, w: 120, h: 40}
    st.view.minimumValue = 1
    st.view.maximumValue = 100
    st.view.stepValue    = 1
    st.centered = false
  end


end

