class AgeVerificationScreen < PM::Screen

  title "Alterskontrolle"
  stylesheet AgeVerificationStylesheet

  # Initial view setup
  def on_load

    @num  = 9999
    @num0 = 1
    @num1 = 0
    @num2 = 0
    @num3 = 0

    view = append(UIView, :view)
    back_view = append(UIView, :back_field)
    back_view.append(UIButton, :back_button).on(:touch) do
       back_pressed
     end
    back_view.append(UILabel, :back_label)
    view.append(UIImageView, :babbo)
    right_view = view.append(UIView, :right_view)
    right_view.append(UIImageView, :logo)
    right_view.append(UILabel, :label1)
    right_view.append(UILabel, :label2)


     @year_picker = right_view.append!(UIPickerView, :age_input_field)
     @year_picker.delegate = self
     @year_picker.dataSource = self

     right_view.append(UIButton, :age_verification_button).on(:touch) do
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
    if(Time.now.year - @num > 17 && Time.now.year - @num < 121)
       StartScreen.next_screen= :parent_menu
       rmq.screen.open_root_screen(StartScreen)
    else
      StartScreen.next_screen= :kids_menu
      rmq.screen.open_root_screen(StartScreen)
    end

  end

  def pickerView(pickerView, numberOfRowsInComponent:component)
    elements = 0

    elements = 10 if component == 3
    elements = 10 if component == 2
    elements = 10 if component == 1
    elements = 2 if component == 0

    elements
  end

  def pickerView(pickerView, titleForRow:row, forComponent:component)
    if(component == 0)
      (row+1).to_s
    else
      row.to_s
    end
  end

  def numberOfComponentsInPickerView(pickerView)
    4
  end

  def pickerView(pickerView, didSelectRow:row, inComponent:component)

    @num0 = row+1 if component == 0
    @num1 = row   if component == 1
    @num2 = row   if component == 2
    @num3 = row   if component == 3

    @num = @num0 * 1000 + @num1 * 100 + @num2 * 10 + @num3

    lp @num
  end

end