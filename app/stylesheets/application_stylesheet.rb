class ApplicationStylesheet < RubyMotionQuery::Stylesheet
  def application_setup
    StandardAppearance.apply app.window

    # Add a new standard font (usually in ApplicationStylesheet.rb)
    font_regular = 'Enriqueta-Regular'
    font_bold = 'Enriqueta-Bold'

    font.add_named :pad_xs,     font_regular, 10
    font.add_named :pad_small,  font_regular, 14
    font.add_named :pad_medium, font_regular, 18
    font.add_named :pad_large,  font_regular, 26
    font.add_named :pad_xl,     font_regular, 45
    font.add_named :pad_xxl,    font_regular, 90

    font.add_named :pad_xs_bold,     font_bold, 10
    font.add_named :pad_small_bold,  font_bold, 14
    font.add_named :pad_medium_bold, font_bold, 18
    font.add_named :pad_large_bold,  font_bold, 26
    font.add_named :pad_xl_bold,     font_bold, 45
    font.add_named :pad_xxl_bold,    font_bold, 90

    font.add_named :phone_xs,     font_regular, 6
    font.add_named :phone_small,  font_regular, 8
    font.add_named :phone_medium, font_regular, 10
    font.add_named :phone_large,  font_regular, 12
    font.add_named :phone_xl,     font_regular, 28
    font.add_named :phone_xxl,    font_regular, 55

    font.add_named :phone_xs_bold,     font_bold, 6
    font.add_named :phone_small_bold,  font_bold, 8
    font.add_named :phone_medium_bold, font_bold, 10
    font.add_named :phone_large_bold,  font_bold, 12
    font.add_named :phone_xl_bold,     font_bold, 28
    font.add_named :phone_xxl_bold,    font_bold, 55

  end
end

