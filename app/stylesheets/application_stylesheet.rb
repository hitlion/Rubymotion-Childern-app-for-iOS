class ApplicationStylesheet < RubyMotionQuery::Stylesheet
  def application_setup
    StandardAppearance.apply app.window
  end
end

