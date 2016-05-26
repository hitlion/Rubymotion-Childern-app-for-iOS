class UpdateManager

  class << self
    attr_accessor :instance

    # Return the shared +UpdateManager+ instance.
    def get
      UpdateManager.instance ||= UpdateManager.new
    end
  end

  attr_accessor :updates, :finished_updates, :results, :errors, :finished

  def initialize
    @finished_updates = []
    @results = []
    @errors = []
    @finished = false
    create_update_list
  end


  # Register your updates in this method
  # just add the name as string to the list
  def create_update_list
    list = []

    list << Update_V_1_2_0.get(self) if defined? Update_V_1_2_0

    @updates = []
    @updates = list
    @unfinished_updates = @updates.clone
  end

  # After calling this Method, the manager check every update in +@updates+
  # and run it if necessary
  def run
    @updates.each do |update|
      update.run
    end
  end

  # Set the method and class which should be invoked after the update finished
  def call_after_update (source, name: name)
    @source = source
    @name = name
  end

  def continue_app
    @results.each do |result|
      NSLog('Update Manager: %@', result)
    end

    if @errors.empty?
      @finished = true
      @source.send(@name) if @source.respond_to? @name
    else
      message = ''
      @errors.each do |error|
        message += error + "\n\n"
      end

      app.alert(title: 'Update Error occurred', message: message, actions: ['OK']) do
        @finished = true
        @source.send(@name) if @source.respond_to? @name
      end
    end

    NSUserDefaults.standardUserDefaults.setObject(app.version, forKey:'de.tuluh_tec.babbo_voco.installed_version')
    NSUserDefaults.standardUserDefaults.synchronize

  end

  # Every update calls this Method after finishing.
  def update_finished (id, result: result, error: error)
    @results += result unless result.nil? || result == ''
    @errors += error unless error.nil? || error == ''

    update = @unfinished_updates.find {|update| update.id == id}
    @unfinished_updates.delete(update) unless update.nil?

    if @unfinished_updates.empty?
      continue_app
    end

  end

end
