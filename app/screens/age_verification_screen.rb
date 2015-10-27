class AgeVerificationScreen < PM::Screen

  title "Alterskontrolle"
  stylesheet AgeVerificationStylesheet

  # Initial view setup
  def on_load
    set_nav_bar_button :right, title: "Back", action: :back_pressed
    set_nav_bar_button :right, title: "Ok", action: :ok_pressed
  end

  def will_appear

  end

  def back_pressed
    puts 'back'
  end

  def ok_pressed
    puts 'ok'
  end

end