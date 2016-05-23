module Story
  module Changelog
    # A Runner is a class used to apply a changelog
    # to an instance of StoryBundle to replay the described changes.
    class Remover
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
          script_context.addNativeMethodArg6('meta'  , withBlock: ->(arg1, arg2, arg3, arg4, arg5, arg6){ self.meta(arg1, arg2, arg3, arg4, arg5, arg6) }.weak! )

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
      def meta(dataset_id, set_name, thumbnail, timestamp, identifier, status)
        return unless thumbnail != ''
        path = @bundle.asset_path (thumbnail)
        lp path
        NSFileManager.defaultManager.removeItemAtPath(path, error:nil)
      end

      # @private
      def copy(path)

      end

      # @private
      def change(path, args)
        return unless args[:object_content]
        path = @bundle.asset_path(args[:object_content])
        lp path
        NSFileManager.defaultManager.removeItemAtPath(path, error:nil)
      end

    end
  end
end

