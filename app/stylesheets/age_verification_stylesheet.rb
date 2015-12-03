class AgeVerificationStylesheet < ApplicationStylesheet

  def setup
  end

  def root_view(st)
    st.background_color = rmq.color.babbo_bar_grey
  end

  def view(st)
    st.frame = {w: device.screen_width, h: device.screen_height, centered: :horizontal}
  end

  def back_field(st)
    st.frame = {w: device.screen_width, h: 0.1 * device.screen_height, fb:10}
  end

  def babbo(st)
    st.frame = {l: 30, t: 0.15 * device.screen_height, w: 0.3 * device.screen_width, h: 0.6 * device.screen_height}
    st.image = image.resource('Babbo_1')
  end

  def right_view(st)
    st.frame = {l: 30, t: 0.1 * device.screen_height, fr: 30, h: 0.6 * device.screen_height}
  end

  def logo(st)
    st.frame = {w: 0.15 * device.screen_width, t:0, h: 0.2 * device.screen_height, centered: :horizontal}
    st.image = image.resource('Logo_Black')

  end

  def label1(st)
    st.frame = {below_prev: 0.025 * device.screen_height, l: 30, fr: 30, h: 0.05 * device.screen_height,  centered: :horizontal}
    st.text = "Elternbereich"
    st.font = UIFont.fontWithName("Enriqueta-Bold", size: 40)
    st.text_alignment = :center
    st.color = rmq.color.babbo_orange
  end

  def label2(st)
    st.frame = {below_prev:0.025 * device.screen_height, l:30, fr:30, h: 0.05 * device.screen_height,  centered: :horizontal}
    st.text = "In welchem Jahr bist du geboren?"
    st.font = UIFont.fontWithName("Enriqueta-Regular", size:20)
    st.text_alignment = :center
    st.color = rmq.color.black
  end

  def age_input_field(st)
    st.frame = {w: 0.3 * device.screen_width, below_prev:0.025 * device.screen_height,  h: 162, centered: :horizontal}
  end

  def go_on_button(st)
    st.frame = {w: 0.15 * device.screen_width, t:0.75 * device.screen_height,  h: 0.05 * device.screen_height, centered: :horizontal}
    st.color = rmq.color.white
    st.text = "Weiter"
    st.font = UIFont.fontWithName("Enriqueta-Regular", size:25)
  end

  def left_button(st)
    st.frame = {l: 10, w: 0.075 * device.screen_width, h: 0.1 * device.screen_height, centered: :vertical }
    st.image = image.resource("babbo_left_button.png")
  end

  def left_label(st)
    st.frame = {l: 0.1 * device.screen_width, w: 0.3 * device.screen_width, h: 0.05 * device.screen_height, centered: :vertical}
    st.text = "Zurück zum Spielplatz"
    st.font = UIFont.fontWithName("Enriqueta-Regular", size:20)
    st.text_alignment = :center
    st.color = rmq.color.black
  end
end

