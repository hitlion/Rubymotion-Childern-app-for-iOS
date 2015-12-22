# A few helpers for internal beta releases
module Devmode
  attr_accessor :devmode_start_screen

  # @private
  def setupDevmode
    devmode_config = File.join(Dir.system_path(:documents), 'devmode.yml')
    devmode_log    = File.join(Dir.system_path(:documents), 'errors.log')

    # check if devmode options are present and readable
    return unless File.exists? devmode_config
    options = YAML.load(File.read(devmode_config))
    return if options.nil? || options == {}

    lp 'Checking devmode options..'

    if options[:old_ui]
      lp 'devmode: starting in classic ui'
      self.devmode_start_screen = :story_list
    end

    if options[:error_log]
      truncate = options.fetch(:keep_log, false) == false

      lp "devmode: redirecting NSLog to errors.log, #{truncate ? 'overwriting' : 'appending'}"
      NativeUtils.redirectNSLogToPath(devmode_log, truncate: truncate)
    end
  end
end

