class StoryPlayerStylesheet < ApplicationStylesheet
  def root(st)
    st.frame = :full
    st.clips_to_bounds = true
  end

  def scene_player(st)
    st.frame = :full
  end
end

