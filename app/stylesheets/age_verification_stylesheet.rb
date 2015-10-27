class AgeVerificationStylesheet < ApplicationStylesheet

  def setup
  end

  def root_view(st)
    st.background_color = rmq.color.babbo_orange
  end

  def logo(st)
    st.frame = {l:150, fr:150, below_prev:20, h:200}
    st.image = image.resource('logo')
    #st.background_color = color.white
  end

  def age_input_field(st)
    st.frame = {w: 225, below_prev:10, h:45, centered: :horizontal}
    st.background_color = color.orange
  end

  def age_input_field1(st)
    st.frame = {l:5, w:50, t:5, fb:5}
    st.background_color = color.white
  end

  def age_input_field2(st)
    st.frame = {rop:5, w:50, t:5, fb:5}
    st.background_color = color.white
  end

  def age_input_field3(st)
    st.frame = {rop:5, w:50, t:5, fb:5}
    st.background_color = color.white
  end

  def age_input_field4(st)
    st.frame = {rop:5, w:50, t:5, fb:5}
    st.background_color = color.white
  end

  def age_verification_button(st)
    st.frame = {w: 225, below_prev:10, h:45, centered: :horizontal}
    st.text = "OK"
    st.background_color = color.orange
  end

end

