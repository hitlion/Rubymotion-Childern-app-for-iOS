class StartScreenStyleSheet < ApplicationStylesheet


  def setup
  end

  def root_view(st)
    st.background_color = rmq.color.babbo_orange
  end

  def logo(st)
    st.frame = {l:100, fr:100, below_prev:20, fb:20}
    st.image = image.resource('logo')
  end

end

