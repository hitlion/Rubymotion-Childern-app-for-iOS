class StoryEditorToolboxStylesheetOld < ApplicationStylesheet
  def setup
  end

  def root( st )
    st.frame = {x: 0, y: 0, w: 250, h: device.screen_height}
    st.alpha = 1.0
    st.tint_color = rmq.color.black
    st.background_color = rmq.color.babbo_orange
    st.corner_radius = 12.5
  end

  def background_layer( st )
    st.frame = {t: 5, l: 5, fr: 5, fb: 5}
    st.background_color = rmq.color.white
    st.corner_radius = 12.5
  end

  def object_name_label( st )
    st.frame = {t: 0.05 * device.screen_height, l: 10, fr: 10, h: 0.05 * device.screen_height}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_BOLD, 20)
    st.text  = ''
    st.color = rmq.color.babbo_orange
    st.text_alignment = :center
  end

  def edit_name( st )
    st.frame = {bp: 5, l: 10, fr: 10, h: 0.075 * device.screen_height}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_REGULAR, 18)
    st.text  = 'Name ändern'
    st.color = rmq.color.white
    st.background_color = rmq.color.light_gray
    st.corner_radius = 12.5
  end

  def edit_content( st )
    st.frame = {bp: 5, l: 10, fr: 10, h: 0.075 * device.screen_height}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_REGULAR, 18)
    st.text  = 'Inhalt ändern'
    st.color = rmq.color.white
    st.background_color = rmq.color.light_gray
    st.corner_radius =  12.5
  end

  def resize_width_label( st )
    st.frame = {bp: 50, l: 10, fr: 10, h: 0.05 * device.screen_height}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_REGULAR, 20)
    st.text  = 'Breite:'
    st.text_alignment = :center
  end

  def resize_width_slider( st )
    st.frame = {bp: 5, l: 10, fr: 10, h: 0.05 * device.screen_height}
    st.view.minimumValue = 0.01
    st.view.maximumValue = 1.0
  end

  def resize_height_label( st )
    st.frame = {bp: 5, l: 10, fr: 10, h: 0.05 * device.screen_height}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_REGULAR, 20)
    st.text  = 'Höhe:'
    st.text_alignment = :center
  end

  def resize_height_slider( st )
    st.frame = {bp: 5, l: 10, fr: 10, h: 0.05 * device.screen_height}
    st.view.minimumValue = 0.01
    st.view.maximumValue = 1.0
  end

  def layer_select_label( st )
    st.frame = {bp: 25, l: 10, fr: 10, h: 0.05 * device.screen_height}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_REGULAR, 20)
    st.text  = 'Ebene:'
    st.text_alignment = :center
  end

  def layer_select_stepper( st )
    st.frame = {bp: 5, h: 0.05 * device.screen_height, centered: :horizontal}
    st.view.minimumValue = 0
    st.view.maximumValue = 100
    st.border_color = rmq.color.black
  end

  def transparency_label( st )
    st.frame = {bp: 25, l: 10, fr: 10, h: 0.05 * device.screen_height}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_REGULAR, 20)
    st.text  = 'Transparenz:'
    st.text_alignment = :center
  end

  def transparency_stepper( st )
    st.frame = {bp: 5, h: 0.05 * device.screen_height, centered: :horizontal}
    st.view.minimumValue = 0.0
    st.view.maximumValue = 1.0
    st.view.stepValue    = 0.05
  end
end

