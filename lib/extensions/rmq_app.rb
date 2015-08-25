module RubyMotionQuery
  # Extensions to RMQ::App
  class App
    # Check if the application is an Ad-Hoc release
    #
    # This method checks the boolean Info.plist key +IsAdHocRelease+
    # defaulting to +false+ if it doesn't exist.
    #
    # @return [Boolean]
    def self.ad_hoc_release?
      @_ad_hoc_release = !!info_plist.fetch(:IsAdHocRelease, false) if @_ad_hoc_release.nil?
      @_ad_hoc_release
    end
  end
end

