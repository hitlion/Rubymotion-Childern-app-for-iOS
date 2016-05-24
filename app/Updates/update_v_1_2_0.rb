class Update_V_1_2_0

  class << self
    attr_accessor :successful, :instance

    # Return the shared +Update_V_1_2_0+ instance.
    def get
      Update_V_1_2_0.instance ||= Update_V_1_2_0.new
    end
  end

  def run
    return unless Update_V_1_2_0.successful.nil?

    NSLog('Perform Update for version 1.2.0')

    update_bundles = []

    Dir.glob("#{File.join(Dir.system_path(:documents), 'Bundles')}/*.babbo").each do |bundle_path|
      lp name = bundle_path.split('/').last
      nr = name.split('_')[1]
      lp nr

      unless nr == '0'
        update_bundles << bundle_path
      end
    end

    lp update_bundles

    app.alert(title: "Neue Story!", message: "Eine neue Story wurde hinzugefügt.", actions: ['OK']) do
      Update_V_1_2_0.successful = true

      NSNotificationCenter.defaultCenter.postNotificationName('UpdateFinished',
                                                              object:nil,
                                                              userInfo: {
                                                                  :update => Update_V_1_2_0.get
                                                              })
    end
  end

end