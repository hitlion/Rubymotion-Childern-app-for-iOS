class UpdateManager

  class << self
    attr_accessor :instance

    # Return the shared +UpdateManager+ instance.
    def get
      UpdateManager.instance ||= UpdateManager.new
    end
  end

  attr_accessor :update_list, :finished_updates

  def initialize
    @finished_updates = []
    create_update_list

    NSNotificationCenter.defaultCenter.removeObserver(self)

    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector: 'update_finished:',
                                                   name: 'UpdateFinished',
                                                   object: nil)
  end


  # Register your updates in this method
  # just add the name as string to the list
  def create_update_list
    list = []

    list << Update_V_1_2_0.get if defined? Update_V_1_2_0

    @update_list = []
    @update_list = list
  end

  # After calling this Method, the manager check every update in +@update_list+
  # and run it if necessary
  def run
    @update_list.each do |update|
      update.run
    end
  end

  # Set the method and class which should be invoked after the update finished
  def call_after_update (source, name: name)
    @source = source
    @name = name
  end

  def update_finished (notification)
    update = notification.userInfo[:update]
    unless @finished_updates.include? update
      @finished_updates << update
    end

    if @finished_updates.length == @update_list.length
      if @source.respond_to? @name
        @source.send(@name)
      end
    end

  end

end
