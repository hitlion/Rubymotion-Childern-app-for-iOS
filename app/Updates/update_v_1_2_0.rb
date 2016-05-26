class Update_V_1_2_0

  attr_accessor :id, :finished, :successful, :results, :errors, :manager

  class << self
    attr_accessor :instance

    # Return the shared +Update_V_1_2_0+ instance.
    def get (manager)
      Update_V_1_2_0.instance ||= Update_V_1_2_0.new (manager)

    end
  end

  def initialize (manager)
    @id = '1.2.0'
    @finished = false
    @successful = false
    @errors = []
    @results = []
    @manager = WeakRef.new(manager)
  end

  def run
    NSLog('Perform Update for version 1.2.0')
    @successful = true
    @successful = update_1_2_0_a && @successful

    update_finished
  end

  def update_finished
    @manager.update_finished(@id, result: @results, error: @errors) if @manager.respond_to?('update_finished:result:error:')
  end

  # define update parts here (name them update_version_a-z)

  def update_1_2_0_a

    error = nil
    if TTUtil.isVersion(NSUserDefaults.standardUserDefaults.stringForKey('de.tuluh_tec.babbo_voco.installed_version'), greaterThan: '1.2.0')
      @results << 'Update 1.2.0_a is not necessary because pre installed version was at less 1.2.0.'
      return true
    end

    update_bundles = []

    Dir.glob("#{File.join(Dir.system_path(:documents), 'Bundles')}/*.babbo").each do |bundle_path|
      name = bundle_path.split('/').last
      nr = name.split('_')[1]

      unless nr == '0'
        update_bundles << bundle_path
      end
    end

    unless update_bundles.empty?
      #update is necessary
      update_bundles.each do |bundle|
        folder_name = bundle.split('/').last
        original_name = folder_name.split('_').first + '_0_0.babbo'

        file_manager = NSFileManager.defaultManager()

        if Dir.exist? File.join(Dir.system_path(:documents), 'Bundles', original_name)
          # original folder is installed

          # copy content files
          original_content_path = File.join(Dir.system_path(:documents), 'Bundles', original_name, 'content')

          Dir.glob("#{bundle}/content/*").each do |file|
            name = file.split('/').last
            des_path = File.join(original_content_path, name)

            unless File.exist?(des_path)
              file_manager.copyItemAtPath(file, toPath: des_path, error: error)
            end
          end
          # copy changes_branch_*.js
          Dir.glob("#{bundle}/SMIL/changes_branch_*").each do |branch_file|
            name = branch_file.split('/').last
            number = name.split('.').first.split('_').last
            number = number.to_i

            @top_branch_number ||= 0

            @branch = branch_file if number > @top_branch_number
            @top_branch_number = number
          end

          original_smil_path = File.join(Dir.system_path(:documents), 'Bundles', original_name, 'SMIL')

          @top_branch_number = 0
          Dir.glob("#{original_smil_path}/changes_branch_*").each do |branch_file|
            name = branch_file.split('/').last
            number = name.split('.').first.split('_').last
            number = number.to_i

            @top_branch_number ||= 0

            @top_branch_number = number if number > @top_branch_number
          end

          des_path = File.join(original_smil_path, "changes_branch_#{@top_branch_number + 1}.js")
          file_manager.copyItemAtPath(@branch, toPath: des_path, error: error)

          file_manager.removeItemAtPath(bundle, error: error)

        else
          # original folder is not installed
          lp 'create original'
          new_path = File.join(Dir.system_path(:documents), 'Bundles', original_name)
          file_manager.copyItemAtPath(bundle, toPath: new_path, error: error)
          file_manager.removeItemAtPath(bundle, error: error)


          if Dir.exist? File.join(Dir.system_path(:documents), 'Bundles', original_name)
            # search the highest branch
            Dir.glob("#{File.join(Dir.system_path(:documents), 'Bundles', original_name)}/SMIL/changes_branch_*.js").each do |path|
              name = path.split('/').last
              number = name.split('.').first.split('_').last

              number = number.to_i

              @top_branch ||= number
              @top_branch = number if number > @top_branch
            end

            # set highest branch number to 1
            top_branch_path = File.join(Dir.system_path(:documents), 'Bundles', original_name, "SMIL/changes_branch_#{@top_branch}.js")

            new_path = File.join(Dir.system_path(:documents), 'Bundles', original_name, "SMIL/changes_branch_1.js" )

            file_manager.removeItemAtPath(new_path, error: nil)
            file_manager.copyItemAtPath(top_branch_path, toPath: new_path, error: error)

            # remove all other than the top_branch file (now the file with *_1.js)
            Dir.glob("#{File.join(Dir.system_path(:documents), 'Bundles', original_name)}/SMIL/changes_branch_*.js").each_with_index do |path,index|
              if index > 0
                file_manager.removeItemAtPath(path, error: nil)
              end
            end
          end
        end
      end

      if error
        @results << 'Update 1.2.0_a: Update runs with Errors.'
        @errors << error.localizedDescription
        return false
      else
        @results << 'Update 1.2.0_a: Update runs successful.'
        return true
      end

    else
      # no update necessary
      @results << 'Update 1.2.0_a: Update runs successful (no actions needed).'
      return true
    end
  end



end