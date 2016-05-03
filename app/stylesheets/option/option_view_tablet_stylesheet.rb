class OptionViewTabletStylesheet < ApplicationStylesheet
  def setup
  end

  def root( st )
    st.frame = {l: device.screen_width, t: 0.125 * device.screen_height, w: 1 * device.screen_width, h: 0.875 * device.screen_height}
    st.alpha = 1.0
    st.tint_color = rmq.color.black
    st.background_color = rmq.color.clear
    st.corner_radius = 0
  end

  def layer (st)
    st.frame = {l: 0.0 * device.screen_width, t: 0.0 * device.screen_height, w: 1 * device.screen_width, h: 0.875 * device.screen_height}
    st.alpha = 0.75
    st.background_color = rmq.color.black
  end

  def option_background (st)
    st.frame = {l: 0.75 * device.screen_width, t: 0.05 * device.screen_height, w: 0.3 * device.screen_width, h: 0.800 * device.screen_height}
    st.background_color = rmq.color.babbo_bar_grey
    st.border_width = 1
    st.border_color = rmq.color.babbo_line_grey
    st.corner_radius = 25
  end

  def image (st)
    st.frame = {l: 0.05 * device.screen_width, t: 0.025 * device.screen_height, w: 0.15 * device.screen_width, h: 0.2 * device.screen_height}
    st.background_color = rmq.color.clear
    st.image = rmq.image.resource('babbo_icons/babbo_head.png')
    st.border_width = 1
    st.corner_radius = 0.1 * device.screen_height
    st.border_color = rmq.color.babbo_orange
  end

  def name (st)
    st.frame = {l: 0.0 * device.screen_width, t: 0.25 * device.screen_height, w: 0.25 * device.screen_width, h: 0.05 * device.screen_height}
    st.background_color = rmq.color.clear
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:large))
    st.text  = 'Babbo-Voco'
    st.color = rmq.color.babbo_orange
    st.text_alignment = :center

  end

  def button_1 (st)
    st.frame = {l: 0.025 * device.screen_width, t: 0.35 * device.screen_height, w: 0.2 * device.screen_width, h: 0.05 * device.screen_height}
    st.text = 'Inhalte wiederherstellen'
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:small))
    st.color = rmq.color.black
    st.background_color = rmq.color.white
    st.corner_radius =  15
    st.border_width = 1
    st.border_color = rmq.color.babbo_orange
  end

  def button_2 (st)
    st.frame = {l: 0.025 * device.screen_width, t: 0.45 * device.screen_height, w: 0.2 * device.screen_width, h: 0.05 * device.screen_height}
    st.text = 'Über uns'
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:small))
    st.color = rmq.color.black
    st.background_color = rmq.color.white
    st.corner_radius =  15
    st.border_width = 1
    st.border_color = rmq.color.babbo_orange
  end

  def logo (st)
    st.frame = {l: 0.05 * device.screen_width, t: 0.525 * device.screen_height, w: 0.15 * device.screen_width, h: 0.2 * device.screen_height}
    st.background_color = rmq.color.clear
    st.image = rmq.image.resource('babbo_icons/logo_orange.png')
  end

  def version (st)
    st.frame = {l: 0.0 * device.screen_width, t: 0.75 * device.screen_height, w: 0.25 * device.screen_width, h: 0.05 * device.screen_height}
    st.background_color = rmq.color.clear
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:medium))
    st.text  = app.version
    st.color = rmq.color.black
    st.text_alignment = :center
  end

end

