class AgeVerificationStylesheet < ApplicationStylesheet

  def setup
  end

  def root_view(st)
    st.background_color = rmq.color.babbo_orange
  end

  def logo(st)
    st.frame = {w: 0.5 * device.screen_width, below_prev:20, h: 0.5 * device.screen_height, centered: :horizontal}
    st.image = image.resource('Logo')
    #st.background_color = color.white
  end

  def age_input_field(st)
    st.frame = {w: 0.5 * device.screen_width, below_prev:10,  h: 0.2 * device.screen_height, centered: :horizontal}
    #st.background_color = color.orange
  end


  def age_verification_button(st)
    st.frame = {w: 0.5 * device.screen_width, below_prev:10,  h: 0.2 * device.screen_height, centered: :horizontal}
    st.text = "OK"
    #st.background_color = color.orange
  end

end

