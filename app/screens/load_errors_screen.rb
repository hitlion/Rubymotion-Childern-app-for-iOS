class LoadErrorsScreen < PM::TableScreen
  stylesheet LoadErrorsStylesheet

  attr_accessor :load_errors

  # Return the structured table data for ProMotion
  def table_data
    [{
      cells: @load_errors.map do |error|
        {
          title: error,
          style: { text_color: rmq.color.red },
          action: :show_single_error,
          arguments: error
        }
      end
    }]
  end

  # @private
  def show_single_error( error )
      app.alert(title: 'Fehler:',
                message: error)
  end
end

