module LoggerPrint
  module_function
  def split_ansi( string )
    define_colors unless rmq.color.respond_to? :term_white

    parts = []
    # basically reverse what MotionPrint does for colors
    # und split the string on color boundaries
    colors = [
      rmq.color.term_gray, rmq.color.term_red, rmq.color.term_green,
      rmq.color.term_yellow, rmq.color.term_blue, rmq.color.term_magenta,
      rmq.color.term_cyan, rmq.color.term_white
    ]

    string.split(/\e\[[01]/).each do |part|
      if part.start_with? 'm'
        parts << [rmq.color.term_white, part[1..-1]]
      elsif part.start_with? ';'
        color_key = part[/^;3(\d)m/,1].to_i
        parts << [colors[color_key], part[4..-1]]
      else
        parts << [rmq.color.term_white, part]
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
                NSFontAttributeName => rmq.font.with_name('Menlo', 10) }
      text  = NSAttributedString.alloc.initWithString(part[1],
                                                      attributes: attrs)

      res.appendAttributedString(text)
    end
    res
  end

  def define_colors
    rmq.color.add_named(:term_gray   , '#bebebe')
    rmq.color.add_named(:term_red    , '#fc2b33')
    rmq.color.add_named(:term_green  , '#b0cc71')
    rmq.color.add_named(:term_yellow , '#fdb14b')
    rmq.color.add_named(:term_blue   , '#82c1d9')
    rmq.color.add_named(:term_magenta, '#dc99cd')
    rmq.color.add_named(:term_cyan   , '#89cfc4')
    rmq.color.add_named(:term_white  , '#e8e8e8')
  end
end

class Kernel
  def lp(object={}, options={})
    return unless device.is_simulator? || app.development? || app.ad_hoc_release?

    log_js = options.delete(:log_js) || false
    if device.is_simulator?
      mp object, options
    end

    if app.development? || app.ad_hoc_release?
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

