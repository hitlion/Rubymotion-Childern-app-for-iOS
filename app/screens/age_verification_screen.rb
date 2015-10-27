class AgeVerificationScreen < PM::Screen

  title "Alterskontrolle"
  stylesheet AgeVerificationStylesheet

  # Initial view setup
  def on_load
    set_nav_bar_button :left, title: "Back", action: :back_pressed
    set_nav_bar_button :right, title: "Ok", action: :ok_pressed

    append(UIImageView, :logo)
    @textfield = append(UIView, :age_input_field)
    @textfield.append(UITextField, :age_input_field1)
    @textfield.append(UITextField, :age_input_field2)
    @textfield.append(UITextField, :age_input_field3)
    @textfield.append(UITextField, :age_input_field4)

    append(UIButton, :age_verification_button).on(:touch) do
      ok_pressed
    end
  end

  def will_appear

  end

  def back_pressed
    StartScreen.next_screen= :kids_menu
    rmq.screen.close(to_screen: :root)
  end

  def ok_pressed
    StartScreen.next_screen= :parent_menu
    rmq.screen.close(to_screen: :root)
  end

end