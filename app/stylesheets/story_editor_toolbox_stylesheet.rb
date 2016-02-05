class StoryEditorToolboxStylesheet < ApplicationStylesheet
  def setup
  end

  def root( st )
    st.frame = {x: 0, y: 0, w: 200, h: device.screen_height}
    st.alpha = 1.0
    st.tint_color = rmq.color.black
    st.background_color = rmq.color.clear
  end

  def background_layer( st )
    st.frame = {t: 0, l: 0, fr: 0, fb: 28}
    st.background_color = rmq.color.white
  end

  def background_ornament_left( st )
    st.frame = {l: 0, t: device.screen_height - 28, w: 200, h: 28}
    st.image = image.resource_resizable('corner_left_resizeable', top: 0, left: 63, right: 0, bottom: 0)
  end

  def background_ornament_right( st )
    st.frame = {l: 0, t: device.screen_height - 28, w: 200, h: 28}
    st.image = image.resource_resizable('corner_right_resizeable', top: 0, left: 0, right: 63, bottom: 0)
  end

  def object_name_label( st )
    st.frame = {t: 5, l: 5, fr: 5, h: 18}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_BOLD, 16)
    st.text  = ''
    st.color = rmq.color.babbo_orange
    st.text_alignment = :center
  end

  def edit_name( st )
    st.frame = {bp: 5, l: 5, fr: 5, h: 25}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_REGULAR, 14)
    st.text  = 'Name ändern'
    st.color = rmq.color.white
    st.background_color = rmq.color.light_gray
    st.corner_radius = 12.5
  end

  def edit_content( st )
    st.frame = {bp: 5, l: 5, fr: 5, h: 25}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_REGULAR, 14)
    st.text  = 'Inhalt ändern'
    st.color = rmq.color.white
    st.background_color = rmq.color.light_gray
    st.corner_radius =  12.5
  end

  def resize_width_label( st )
    st.frame = {bp: 5, l: 5, fr: 5, h: 18}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_REGULAR, 16)
    st.text  = 'Breite:'
    st.text_alignment = :center
  end

  def resize_width_slider( st )
    st.frame = {bp: 5, l: 5, fr: 5, h: 10}
    st.view.minimumValue = 0.1
    st.view.maximumValue = 1.0
  end

  def resize_height_label( st )
    st.frame = {bp: 5, l: 5, fr: 5, h: 18}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_REGULAR, 16)
    st.text  = 'Höhe:'
    st.text_alignment = :center
  end

  def resize_height_slider( st )
    st.frame = {bp: 5, l: 5, fr: 5, h: 10}
    st.view.minimumValue = 0.1
    st.view.maximumValue = 1.0
  end

  def layer_select_label( st )
    st.frame = {bp: 5, l: 5, fr: 5, h: 18}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_REGULAR, 16)
    st.text  = 'Ebene:'
    st.text_alignment = :center
  end

  def layer_select_stepper( st )
    st.frame = {bp: 5, l: 5, fr: 5, h: 8}
    st.view.minimumValue = 0
    st.view.maximumValue = 100
    st.border_color = rmq.color.black
    st.centered = true
  end

  def transparency_label( st )
    st.frame = {bp: 5, l: 5, fr: 5, h: 18}
    st.font  = rmq.font.font_with_name(FONT_STANDARD_REGULAR, 16)
    st.text  = 'Transparenz:'
    st.text_alignment = :center
  end

  def transparency_stepper( st )
    st.frame = {bp: 5, l: 5, fr: 5, h: 8}
    st.view.minimumValue = 0.0
    st.view.maximumValue = 1.0
    st.view.stepValue    = 0.05
    st.centered = true
  end
end

