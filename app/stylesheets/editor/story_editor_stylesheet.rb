class StoryEditorStylesheet < ApplicationStylesheet
  def root(st)
    st.frame = :full
    st.clips_to_bounds = true
  end

  def scene_editor(st)
    st.frame = :full
  end
end

