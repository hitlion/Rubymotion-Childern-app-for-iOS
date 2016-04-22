class OverlayViewModuleStylesheet < ApplicationStylesheet
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

  def background_layer (st)
    st.frame = {t: 0.1 * device.screen_height, l: 0.2 * device.screen_width, fr: 0.2 * device.screen_width, fb: 0.1 * device.screen_height}
    st.background_color = rmq.color.white
    st.corner_radius = 12.5
    st.border_width = 5
    st.border_color = rmq.color.babbo_orange
  end

  def top (st)
    st.frame = {t: 0.0 * device.screen_height, l: 0.0 * device.screen_width, fr: 0.0 * device.screen_width, h: 0.3 * device.screen_height}
    st.background_color = rmq.color.clear
  end

  def image_box (st)
    st.frame = {l: 0.02 * device.screen_width, t: 0.02 * device.screen_height, w: 0.2 * device.screen_width, h: 0.2 * device.screen_height}
    st.background_color = rmq.color.clear
    st.image = rmq.image.resource('test_image.png')
  end

  def title_label (st)
    st.frame = {l: 0.25 * device.screen_width, t: 0.02 * device.screen_height, w: 0.25 * device.screen_width, h: 0.05 * device.screen_height}
    st.background_color = rmq.color.clear
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:bold), TTUtil.get_font_size(:large))
    st.text  = 'no text found'
    st.color = rmq.color.babbo_orange
    st.text_alignment = :left
  end

  def cancel_button (st)
    st.frame = {fr: 0.02 * device.screen_width, t: 0.02 * device.screen_height, w: 0.06 * device.screen_width, h: 0.06 * device.screen_width}
    st.background_image = rmq.image.resource('babbo_icons/close.png')
    st.background_color = rmq.color.clear
  end

  def date_label (st)
    st.frame = {l: 0.25 * device.screen_width, t: 0.07 * device.screen_height, w: 0.25 * device.screen_width, h: 0.05 * device.screen_height}
    st.background_color = rmq.color.clear
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:medium))
    st.text  = 'no date found'
    st.color = rmq.color.black
    st.text_alignment = :left
  end

  def left_button (st)
    st.frame = {l: 0.25 * device.screen_width, t: 0.15 * device.screen_height, w: 0.145 * device.screen_width, h: 0.06 * device.screen_height}
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:medium))
    st.text  = 'no text found'
    st.color = rmq.color.white
    st.background_color = rmq.color.babbo_button_orange
    st.corner_radius =  20
  end

  def buying_label (st)
    st.frame = {l: 0.25 * device.screen_width, t: 0.15 * device.screen_height, w: 0.145 * device.screen_width, h: 0.06 * device.screen_height}
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:small))
    st.text  = 'Kauf wird abgeschlossen'
    st.color = rmq.color.white
    st.number_of_lines = 2
    st.background_color = rmq.color.babbo_button_orange
    st.corner_radius =  20
    st.text_alignment = :center
  end

  def right_button (st)
    st.frame = {l: 0.4175 * device.screen_width, t: 0.13 * device.screen_height, w: 0.145 * device.screen_width, h: 0.06 * device.screen_height}
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:medium))
    st.text  = 'no text found'
    st.color = rmq.color.white
    st.background_color = rmq.color.babbo_button_grey
    st.corner_radius =  20
  end

  def line (st)
    st.frame = {l: 0.02 * device.screen_width, fb: 0.0 * device.screen_height, fr: 0.02 * device.screen_width, h: 1}
    st.background_color = rmq.color.black
  end

  def top_button_line (st)
    st.frame = {l: 0.075 * device.screen_width, fb: 0.01 * device.screen_height, fr: 0.075 * device.screen_width, h: 0.06 * device.screen_height}
    st.background_color = rmq.color.clear
  end

  def top_button_1 (st)
    st.frame = {l: 0 * device.screen_width, t: 0.0 * device.screen_height, w: 0.15 * device.screen_width, h: 0.06 * device.screen_height}
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:medium))
    st.text  = 'no text found'
    st.color = rmq.color.black
    st.background_image = rmq.image.resource('button_bg_left_white.png')
  end

  def top_button_2(st)
    st.frame = {l: 0.15 * device.screen_width, t: 0.0 * device.screen_height, w: 0.15 * device.screen_width, h: 0.06 * device.screen_height}
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:medium))
    st.text  = 'no text found'
    st.color = rmq.color.black
    st.background_image = rmq.image.resource('button_bg_middle_white.png')
  end

  def top_button_3 (st)
    st.frame = {l: 0.3 * device.screen_width, t: 0.0 * device.screen_height, w: 0.15 * device.screen_width, h: 0.06 * device.screen_height}
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:medium))
    st.text  = 'no text found'
    st.color = rmq.color.black
    st.background_image = rmq.image.resource('button_bg_right_white.png')
  end

  def status_label (st)
    st.frame = {l: 0.42 * device.screen_width, fb: 0.01 * device.screen_height, fr: 0.02 * device.screen_width, h: 0.06 * device.screen_height}
    st.background_color = rmq.color.clear
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:medium))
    st.text  = 'no status found'
    st.color = rmq.color.black
    st.text_alignment = :center
  end

  def progress_view (st)
    st.frame = {l: 0.02 * device.screen_width, fb: 0.005 * device.screen_height, fr: 0.2 * device.screen_width, h: 0.04 * device.screen_height}
    st.background_color = rmq.color.red
    st.progress_view_style = UIProgressViewStyleDefault
    st.progress_tint_color = rmq.color.babbo_orange
    st.track_tint_color = rmq.color.gray
  end

  def bottom (st)
    st.frame = {bp: 0.0 * device.screen_height, l: 0.0 * device.screen_width, fr: 0.0 * device.screen_width, fb: 0.0 * device.screen_height}
    st.background_color = rmq.color.clear
  end

  def bottom_button_line (st)
    st.frame = {l: 0.15 * device.screen_width, t: 0.02 * device.screen_height, fr: 0.15 * device.screen_width, h: 0.06 * device.screen_height}
    st.background_color = rmq.color.clear
  end

  def bottom_button_1 (st)
    st.frame = {l: 0 * device.screen_width, t: 0.0 * device.screen_height, w: 0.15 * device.screen_width, h: 0.06 * device.screen_height}
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:medium))
    st.text  = 'no text found'
    st.color = rmq.color.black
    st.background_image = rmq.image.resource('button_bg_left_grey.png')
  end

  def bottom_button_2 (st)
    st.frame = {l: 0.15 * device.screen_width, t: 0.0 * device.screen_height, w: 0.15 * device.screen_width, h: 0.06 * device.screen_height}
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:medium))
    st.text  = 'no text found'
    st.color = rmq.color.black
    st.background_image = rmq.image.resource('button_bg_right_white.png')
  end

  def description_box (st)
    st.frame = {l: 0.02 * device.screen_width, t: 0.09 * device.screen_height, fr: 0.02 * device.screen_width, fb: 0.02 * device.screen_height}
    st.background_color = rmq.color.clear
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:medium))
    st.text  = 'no text found'
    st.color = rmq.color.black
    st.editable = false
  end

end

