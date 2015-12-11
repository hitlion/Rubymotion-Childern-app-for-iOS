class StartScreenStyleSheet < ApplicationStylesheet


  def setup
  end

  def root_view(st)
    st.background_color = rmq.color.babbo_orange
  end

  def background(st)
    st.frame = {l:0, fr:0, below_prev:0, fb:0}
    st.image = image.resource('start_screen_background.png')
  end

  def load_progress(st)
    st.frame = {l:100, fr:100, fb:25}
    st.progress_view_style = UIProgressViewStyleDefault
  end
end

