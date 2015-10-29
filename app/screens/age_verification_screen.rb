class AgeVerificationScreen < PM::Screen

  title "Alterskontrolle"
  stylesheet AgeVerificationStylesheet

  # Initial view setup
  def on_load

    @num0 = 0
    @num1 = 0
    @num2 = 0
    @num3 = 0

    set_nav_bar_button :left, title: "Back", action: :back_pressed
    set_nav_bar_button :right, title: "Ok", action: :ok_pressed

    append(UIImageView, :logo)

    @year_picker = append!(UIPickerView, :age_input_field)
    @year_picker.delegate = self
    @year_picker.dataSource = self

    append(UIButton, :age_verification_button).on(:touch) do
      ok_pressed
    end
  end

  def will_appear

  end

  def back_pressed
    StartScreen.next_screen= :kids_menu
    rmq.screen.open_root_screen(StartScreen)
  end

  def ok_pressed
    #if(DateTime.now.year - @num > 17)
    #  StartScreen.next_screen= :parent_menu
    #  rmq.screen.open_root_screen(StartScreen)
    #else
    #  StartScreen.next_screen= :kids_menu
    #  rmq.screen.open_root_screen(StartScreen)
    #end

  end

  def pickerView(pickerView, numberOfRowsInComponent:component)
    10
  end

  def pickerView(pickerView, titleForRow:row, forComponent:component)
    row.to_s
  end

  def numberOfComponentsInPickerView(pickerView)
    4
  end

  def pickerView(pickerView, didSelectRow:row, inComponent:component)

    @num0 = row if component == 0
    @num1 = row if component == 1
    @num2 = row if component == 2
    @num3 = row if component == 3

    @num = @num0 * 1000 + @num1 * 100 + @num2 * 10 + @num3

    lp @num
  end

end