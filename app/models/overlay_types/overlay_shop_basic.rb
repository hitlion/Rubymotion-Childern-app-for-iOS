class OverlayShopBasic
  attr_reader :text_top_button_left, :text_top_button_right, :text_top_button_line_1, :text_top_button_line_2,
              :text_top_button_line_3, :text_top_button_line_4, :text_top_button_line_5,
              :text_bottom_button_line_1, :text_bottom_button_line_2

  def init
    @text_top_button_left   = "Download"
    @text_top_button_right  = "---"
    @text_top_button_line_1 = "---"
    @text_top_button_line_2 = "---"
    @text_top_button_line_3 = "---"
    @text_top_button_line_4 = "---"
    @text_top_button_line_5 = "---"

    @text_bottom_button_line_1 = "Beschreibung"
    @text_bottom_button_line_2 = "Bilder"

    self
  end

end