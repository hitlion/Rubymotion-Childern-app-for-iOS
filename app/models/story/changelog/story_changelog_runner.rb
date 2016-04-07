module Story
  module Changelog
    # A Runner is a class used to apply a changelog
    # to an instance of StoryBundle to replay the described changes.
    class Runner
      # Create a new Runner instance
      def initialize
        @bundle = nil
        @property_map = {
          # 1:1 mappings
          'screen_name'    => 'screen_name',
          'object_name'    => 'object_name',
          'object_content' => 'object_content',
          # attributes 'below' the object_attribute namespace
          'position_x'     => 'object_attribute:position_x',
          'position_y'     => 'object_attribute:position_y',
          'size_x'         => 'object_attribute:size_x',
          'size_y'         => 'object_attribute:size_y',
          'layer'          => 'object_attribute:layer',
          'transparency'   => 'object_attribute:transparency'
        }
      end

      # Apply a given changelog to a bundles objects.
      #
      # @param [StoryBundle] bundle The bundle to modify
      # @param [String] changelog The JavaScript changelog code
      def apply(bundle, changelog)
        @bundle = bundle
        @mapper = ValueMapper.new(@bundle)

        autorelease_pool do
          script_vm = JSVirtualMachine.alloc.init
          script_context = JSContext.alloc.initWithVirtualMachine(script_vm)

          script_context['$']  = JavaScript::Global.new
          script_context.addNativeMethodArg1('copy'  , withBlock: ->(arg){ self.copy(arg) }.weak! )
          script_context.addNativeMethodArg2('change', withBlock: ->(arg1, arg2){ self.change(arg1, arg2) }.weak! )
          script_context.addNativeMethodArg5('meta'  , withBlock: ->(arg1, arg2, arg3, arg4, arg5){ self.meta(arg1, arg2, arg3, arg4, arg5) }.weak! )

          script_context.setExceptionHandler(lambda do |context, value|
            lp "[JavaScriptException]: #{value.toString}",
               force_color: :red, log_js: true
          end)

          script_context.evaluateScript(File.read(Dir.resource('js/changelog.js')))
          script_context.evaluateScript(changelog)

          script_context['$'] = nil
          script_context = nil
          script_vm = nil
        end

        @mapper = nil
        @bundle = nil
      end

      #
      # Mark: methods below are exported to JavaScript
      #

      # @private
      def meta(dataset_id, set_name, thumbnail, timestamp, identifier)
        @bundle.document.dataset_id = dataset_id.to_i unless dataset_id.nil?
        @bundle.document.set_name   = set_name.to_s   unless set_name.nil?
        @bundle.document.thumbnail  = thumbnail.to_s  unless thumbnail.nil?
        @bundle.document.timestamp  = timestamp.to_s  unless timestamp.nil?
        @bundle.document.productIdentifier = identifier.to_s unless identifier.nil?
      end

      # @private
      def copy(path)
        object = @mapper.get_object(path)
        return if object.nil?

        parent = @mapper.get_object(object.path.split(':')[0..-2].join(':'))

        if parent.nil?
          @bundle.document.body.dup_level(object.path)
        else
          if parent.is_a? Story::Level
            if parent.dup_screen(object.path)
            end
          elsif parent.is_a? Story::Screen
            if parent.dup_object(object.path)
            end
          else
            # FIXME: sorry?
          end
        end

        # force a refresh of the internal path cache on next access
        @bundle.instance_eval { @paths = nil }
      end

      # @private
      def change(path, args)
        object = @mapper.get_object(path)
        unless object.nil?
          args.keys.each do |key|
            next unless @property_map.has_key? key
            mapped_key = @property_map[key]
            if @bundle.ruleset.action_for_path(@bundle, "#{path}:#{mapped_key}") == :accept
              lp "Updating '#{path}:#{mapped_key}' -> #{args[key]}"
              @mapper.set_value( "#{path}:#{mapped_key}", args[key])
            else
              lp "Refusing '#{path}:#{mapped_key}' -> #{args[key]}"
            end
          end
        end
      end
    end
  end
end

