class StoryEditorToolboxStylesheet < ApplicationStylesheet
  def setup
  end

  def root( st )
    st.frame = {x: 0, y: 0, w: 0.25 * device.screen_width, h: device.screen_height}
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

  def label (st)
    st.frame = {t:0.025 * device.screen_height, l: 10, fr: 10, h: 0.05 * device.screen_height}
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:bold), TTUtil.get_font_size(:medium))
    st.text  = 'Editierbare Objekte'
    st.color = rmq.color.black
    st.text_alignment = :center
  end

  def table_background (st)
    st.frame = {bp:0.01 * device.screen_height, l: 10, fr: 10, h: 0.45 * device.screen_height}
    st.background_color = rmq.color.babbo_orange
    st.corner_radius = 12.5
  end

  def editable_object_table (st)
    st.frame = {t: 5, l: 5, fr: 5, fb: 5}
    st.background_color = rmq.color.white
    st.corner_radius = 12.5
  end

  def object_name_label (st)
    st.frame = {bp:0.01 * device.screen_height, l: 10, fr: 10, h: 0.05 * device.screen_height}
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:bold), TTUtil.get_font_size(:medium))
    st.text  = 'Object Name'
    st.color = rmq.color.babbo_orange
    st.text_alignment = :center
  end

  def move_object (st)
    st.frame = {bp:0.01 * device.screen_height, l: 10, fr: 10, h: 0.075 * device.screen_height}
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:small))
    st.text  = 'Objekt bewegen'
    st.color = rmq.color.white
    st.background_color = rmq.color.light_gray
    st.corner_radius = 12.5
  end

  def edit_object (st)
    st.frame = {bp:0.01 * device.screen_height, l: 10, fr: 10, h: 0.075 * device.screen_height}
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:small))
    st.text  = 'Objekt bearbeiten'
    st.color = rmq.color.white
    st.background_color = rmq.color.light_gray
    st.corner_radius =  12.5
  end

  def change_view (st)
    st.frame = {bp:0.01 * device.screen_height, l: 10, fr: 10, h: 0.075 * device.screen_height}
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:small))
    st.text  = 'Level wechseln'
    st.color = rmq.color.white
    st.background_color = rmq.color.light_gray
    st.corner_radius =  12.5
  end

  def close_editor (st)
    st.frame = {bp:0.01 * device.screen_height, l: 10, fr: 10, h: 0.075 * device.screen_height}
    st.font  = rmq.font.font_with_name(TTUtil.get_font_standard(:regular), TTUtil.get_font_size(:small))
    st.text  = 'Editor beenden'
    st.color = rmq.color.white
    st.background_color = rmq.color.light_gray
    st.corner_radius =  12.5
  end
end
