module LoggerPrint
  module_function
  def split_ansi( string )
    parts = []
    # basically reverse what MotionPrint does for colors
    # und split the string on color boundaries
    colors = [
      rmq.color.gray, rmq.color.red, rmq.color.green, rmq.color.yellow,
      rmq.color.blue, rmq.color.from_hex('#b98cae'), rmq.color.cyan,
      rmq.color.white
    ]

    string.split(/\e\[[01]/).each do |part|
      if part.start_with? 'm'
        parts << [rmq.color.white, part[1..-1]]
      elsif part.start_with? ';'
        color_key = part[/^;3(\d)m/,1].to_i
        parts << [colors[color_key], part[4..-1]]
      else
        parts << [rmq.color.white, part]
      end
    end

    parts
  end

  module_function
  def attributed_string_from_ansi( string )
    parts = split_ansi(string)
    res = NSMutableAttributedString.alloc.init

    parts.each do |part|
      attrs = { NSForegroundColorAttributeName => part[0],
                NSFontAttributeName => rmq.font.with_name('Menlo-Bold', 10) }
      text  = NSAttributedString.alloc.initWithString(part[1],
                                                      attributes: attrs)

      res.appendAttributedString(text)
    end
    res
  end
end

class Kernel
  def lp(object={}, options={})
    log_js = options.delete(:log_js) || false
    if device.is_simulator?
      return mp object, options
    else
      msg = MotionPrint.logger(object, options)
      string = LoggerPrint.attributed_string_from_ansi(msg + "\n")
      NSNotificationCenter.defaultCenter.postNotificationName('LogMessageAvailable',
                                                              object: string,
                                                              userInfo: nil)

      if log_js
        NSNotificationCenter.defaultCenter.postNotificationName('ScriptMessageAvailable',
                                                                object: string,
                                                                userInfo: nil)
      end
    end
    nil
  end
end

