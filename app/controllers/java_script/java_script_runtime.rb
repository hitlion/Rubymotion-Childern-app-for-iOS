# The JavaScript module contains all classes and methods used
# while executing JavaScript code inside JavaScriptCore and for
# bridging native objects in a secure manner.
module JavaScript
  # The global JavaScriptCore runtime used to execute story slots
  # and events.
  class Runtime
    class << self
      attr_accessor :instance

      # Prepare the JavaScript runtime for processing events
      # related to a given {StoryBundle} and it's scene representation.
      #
      # @param [StoryBundle] story_bundle The active stories bundle.
      # @param [SKScene] scene_root The scene's root node.
      # @return [Boolean] +true+ if preparation was successful
      def prepare_for( story_bundle, scene_root )
        self.instance    = nil
        get.tap do
          self.instance.story_bundle = story_bundle
          self.instance.scene_root   = scene_root
        end
        true
      end

      # Access or create the shared JavaScript runtime.
      # @return [JavaScript::Runtime] The shared runtime instance.
      def get
        self.instance ||= JavaScript::Runtime.new
      end

      # Dispose off of the currently active JavaScript runtime.
      def tear_down
        self.instance = nil
      end

      # see #send_event
      def send_event( target, name, args={} )
        get.send_event(target, name, args)
      end

      # see #call_slot
      def call_slot( target, name )
        get.call_slot(target, name)
      end
    end

    attr_accessor :story_bundle
    attr_accessor :scene_root

    # @private
    def initialize
      @story_bundle = nil
      @scene_root   = nil

      @script_vm    = JSVirtualMachine.alloc.init
      @script_state = begin
        ctx = JSContext.alloc.initWithVirtualMachine(@script_vm)
        ctx.evaluateScript('$$ = new Array();')
        ctx['$$']
      end
    end

    # Send a given event to a target node inside the current scene.
    # This method will create and populate a JavaScript context
    # and then try to execute the slot connected to the event +name+
    # in the object +target+ (if any).
    #
    # Event execution is processed asynchronously und this method
    # will return as soon as the events execution was sheduled.
    #
    # @param [String] target The path to the receiver of the event.
    # @param [String] name The event to trigger.
    # @return [Boolean] +true+ if the event was submitted, +false+ if
    #   an error is detected.
    def send_event( target, name, args={} )
      return false if @story_bundle.nil? || @scene_root.nil?

      receiver = @story_bundle.object_for_path(target)
      if receiver.nil?
        mp "send_event: no receiver named '#{target}' available."
        return false
      end

      if receiver.events[name].nil?
        mp "send_event: receiver '#{target}' does not respond to '#{name}'.",
           force_color: :cyan
        return false
      end

      slot_name = receiver.events[name]
      slot      = receiver.slots[slot_name]

      if slot.nil?
        mp "send_event: receiver '#{target}' has no slot named '#{slot_name}'.",
           force_color: :cyan
        return false
      end

      receiver_proxy = proxy_for_object(scene_object_for_path(target))
      return false if receiver_proxy.nil?

      script_action  = slot.action
      if script_action.nil? || script_action.empty?
        mp "send_event: receiver '#{target}' has not action for slot '#{slot_name}'.",
           force_color: :cyan
        return false
      end

      variables = collect_variables(slot.variables, receiver.path)
      return false if variables.nil?

      async = args[:async].nil? ? false : args[:async]
      dispatch_script_block(receiver_proxy, variables, script_action, async)
      true
    end

    # Send a given event to a target node inside the current scene.
    # This method will create and populate a JavaScript context
    # and then try to execute the slot connected to the event +name+
    # in the object +target+ (if any).
    #
    # Event execution is processed synchronously und this method
    # will not return until the slots execution has finished.
    #
    # @param [String] target The path to the receiver of the event.
    # @param [String] name The event to trigger.
    # @return [Boolean] +true+ if the slot was executed, +false+ if
    #   an error was detected.
    def call_slot( target, name )
      return false if @story_bundle.nil? || @scene_root.nil?

      receiver = @story_bundle.object_for_path(target)
      if receiver.nil?
        mp "send_event: no receiver named '#{target}' available."
        return false
      end

      if receiver.slots[name].nil?
        mp "send_event: receiver '#{target}' has no slot named '#{name}'.",
           force_color: :cyan
        return false
      end

      slot           = receiver.slots[name]

      receiver_proxy = proxy_for_object(scene_object_for_path(target))
      return false if receiver_proxy.nil?

      script_action  = slot.action
      if script_action.nil? || script_action.empty?
        mp "send_event: receiver '#{target}' has not action for slot '#{name}'.",
           force_color: :cyan
        return false
      end

      variables = collect_variables(slot.variables, receiver.path)
      return false if variables.nil?

      # synchronize @script_state
      ctx = JSContext.currentContext
      @script_state = ctx['$$']
      dispatch_script_block(receiver_proxy, variables, script_action, false)
      ctx['$$'] = @script_state
      true
    end

    private

    # Create and execute a +JSContext+ for +action+ injecting
    # +variables+ and +receiver+.
    def dispatch_script_block( receiver, variables, action, async = true )
      block = proc do
        script_context = JSContext.alloc.initWithVirtualMachine(@script_vm)

        if export_variables(variables, script_context)
          # setup fixed globals
          script_context['$']  = JavaScript::Global.new
          script_context['$$'] = @script_state

          unless receiver.nil?
            # body and level may have slots but no proxy representation
            script_context['$self'] = receiver
          end

          script_context.setExceptionHandler(lambda do |context, value|
            mp "[JavaScriptException]: #{value.toString}", force_color: :red
          end)
          script_context.evaluateScript(action)
          @script_state = script_context['$$']
        end
        script_context = nil
      end

      if async # Qeue async event execution
        Dispatch::Queue.new('babbo.js-exec').async { block.call }
      else
        block.call
      end
    end

    # Return the scene node representing +path+.
    #
    # @param [String] path The story path.
    # @return [SKNode] The matching scene node or +nil+ if no such node exists.
    def scene_object_for_path( path )
      if @scene_root.nil?
        mp "Unable to fetch '#{path}' while @scene_root is still nil.",
           force_color: red
        return nil
      end

      case path
      when @scene_root.name
        @scene_root
      when ':body'
        @story_bundle.document.body
      else
        escaped_path = path.gsub(/[\[\]]/){ |c| "\\#{c}" }
        @scene_root.childNodeWithName(escaped_path)
      end
    end

    # Return proxy object suitable for export in a +JSContext+.
    #
    # @param [SKNode] scene_object The scene object to be proxy-wrapped.
    # @return [Object] A suitable proxy wrapper or +nil+ if no wrapper
    #   is available for +scene_object+
    def proxy_for_object( scene_object )
      return nil if scene_object.nil?

      if scene_object.is_a? Scene::PictureNode
        JavaScript::PictureProxy.new(scene_object)
      elsif scene_object.is_a? Scene::AudioNode
        JavaScript::AudioProxy.new(scene_object)
      elsif scene_object.is_a? Scene::VideoNode
        JavaScript::VideoProxy.new(scene_object)
      elsif scene_object.is_a? Scene::RootNode
        JavaScript::ScreenProxy.new(scene_object)
      elsif scene_object.is_a? Story::Body # not a scene object per se..
        JavaScript::FutureProxy.new(scene_object.path)
      elsif scene_object.is_a? JavaScript::FutureProxy
        scene_object
      else
        nil
      end
    end

    # Collect all variables from a {Slot} and resolve
    # them to actual objects inside the current scene.
    #
    # @param [Array<Hash<Symbol,String>>] variables The slots variable list.
    # @param [String] self_path The path used to substitute ':self' references.
    # @return [Hash<String,SKNode>] A new hash with the resolved variables
    #   or +nil+ if not all varibales could be resolved.
    def collect_variables(variables, self_path)
      Hash[variables.map do |var|
        content_path   = var[:content].gsub(':self', self_path)
        content_object = scene_object_for_path(content_path)

        # There is one special case - a different :screen
        # It can't be found because it doesn't exist yet.
        if content_object.nil? and content_path[/:screen\[\s*\d+\s*\]$/]
          content_object = JavaScript::FutureProxy.new(content_path)
        end

        if content_object.nil?
          mp "send_event: Unable to resolve object '#{content_path}'",
             force_color: :red
          return nil
        end

        [var[:name], content_object]
      end]
    end

    # Export a variable dictionary to a +JSContext+.
    # This method tries to export the variable dictionary to +context+
    # by creating a proxy wrapper for each variable and then making this
    # proxy available as +$<variable-name>+.
    #
    # Variable names are processed so that any characters which are
    # not alphanumeric or '_' will be replaced with '_'.
    #
    # @param [Hash<String,SKNode>] variables A variable +Hash+ as returned by
    #   #collect_variables.
    # @param [JSContext] context A JavaScriptCore-Context to export the
    #   variables to.
    # @return [Boolean] +true+ on success, +false+ if any error is detected.
    def export_variables(variables, context)
      return false if variables.nil?

      complete = true
      variables.each_pair do |export_name, scene_object|
        proxy = proxy_for_object(scene_object)
        if proxy.nil?
          mp "send_event: Skipping proxy creation for '#{scene_object}'",
             force_color: :cyan
          complete = false
          next
        end

        export_var = export_name.gsub(/[^a-zA-Z0-9_]+/, '_')
        mp "Exporting #{scene_object} as $#{export_var}",
           force_color: :green
        context["$#{export_var}"] = proxy
      end

      complete
    end
  end
end

