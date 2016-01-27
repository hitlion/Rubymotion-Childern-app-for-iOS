module Story
  module Changelog
    # A mapper between story paths and real object properties
    # FIXME: this class uses a lot of hardcoded knowledge which
    #   relly should be loaded from some filesystem definition.
    class ValueMapper
      # Create a new ValueMapper instance bound to a StoryBundle
      # @param [StoryBundle] bundle the story this mapper will use
      def initialize( bundle )
        @bundle = bundle
      end

      # Split +name+ and return the object path and any attributes
      #
      # @param [String] name A story path which may be specified up
      #   to the object-property level
      #   (:level[x]:screeen[x]:object[x]:object_attributes:position_x)
      # @return [Array<String, String> An array with two elements:
      #   .first: a valid story path up to the level, screen or object
      #   .last: the attribute path on that level ,screen or object
      def get_object_and_attribute( name )
        [
          name.gsub(/(:level\[\d+\](:screen\[\d+\](:object\[\d+\])?)?)(:.*)?/, '\1'),
          name.gsub(/(:level\[\d+\](:screen\[\d+\](:object\[\d+\])?)?)(:(.*))?/, '\5')
        ]
      end

      # Split +name+ and return the associated object from the bundle
      #
      # @see {#get_object_and_attribute}
      # @return [Object] Whichever object +name+ points at or +nil+
      def get_object( name )
        document_path, _  = get_object_and_attribute(name)
        @bundle.object_for_path(document_path)
      end

      # Fetch the value associated with the attribute specified by +name+
      # @see {#get_object_and_attribute} for details an +name+
      # @return [Object] Whichever value +name+ points at
      def get_value( name )
        document_path, attribute_path = get_object_and_attribute(name)

        object = @bundle.object_for_path(document_path)

        if object.nil?
          lp "ValueMapper: #{document_path} object is nil.", force_color: :red
          false
        else
          if object.is_a? Story::Level
            get_level_value(object, attribute_path)

          elsif object.is_a? Story::Screen
            get_screen_value(object, attribute_path)

          elsif object.is_a? Story::Object
            get_object_value(object, attribute_path)
          else
            lp "ValueMapper: object #{document_path} has unsupported type #{object.class}",
               force_color: :red
            false
          end
        end
      end

      # The counterpart to {#get_value}.
      # This method will try to set the object or attribute specified by +name+
      # to +value+
      #
      # @see {#get_object_and_attribute} for a description of +name+
      # @param [Object] value the desired new value
      def set_value( name, value )
        document_path, attribute_path = get_object_and_attribute(name)
        object = @bundle.object_for_path(document_path)

        if object.nil?
          lp "ValueMapper: #{document_path} object is nil.", force_color: :red
        else
          if object.is_a? Story::Screen
            set_screen_value(object, attribute_path, value)

          elsif object.is_a? Story::Object
            set_object_value(object, attribute_path, value)
          else
            lp "ValueMapper: object #{document_path} has unsupported type #{object.class}",
               force_color: :red
            false
          end
        end
      end

      private

      # Return an attribute for a given {Story::Level}
      def get_level_value( level, attribute )
        case attribute.to_sym
          when :level_id
            level.id
          when :path
            level.path
          when :screens
            level.screens
          else
            lp "ValueMapper: #{level.path} has no attribute '#{attribute}'",
               force_color: :red
            false
        end
      end

      # Return an attribute for a given {Story::Screen}
      def get_screen_value( screen, attribute )
        case attribute.to_sym
          when :screen_id
            screen.id
          when :name
            screen.name
          when :path
            screen.path
          when :objects
            screen.objects
          else
            lp "ValueMapper: #{screen.path} has no attribute '#{attribute}'",
               force_color: :red
            false
        end
      end

      # Return an attribute for a given {Story::Object}
      def get_object_value( object, attribute )
        case attribute.to_sym
          when :object_id
            object.id
          when :object_name
            object.name
          when :object_type
            object.type
          when :processable
            object.processable
          when :object_content
            object.content
          when :object_mask
            object.mask
          when :path
            object.path
          # next is object attributes
          when :'object_attribute:position_x'
            object.position.x
          when :'object_attribute:position_y'
            object.position.y
          when :'object_attribute:size_x'
            object.size.width
          when :'object_attribute:size_y'
            object.size.height
          when :'object_attribute:layer'
            object.layer
          when :'object_attribute:transparency'
            object.transparency
          when :'object_attribute:resize'
            object.resize
          when :'object_attribute:moveable'
            object.moveable
          else
            lp "ValueMapper: #{object.path} has no attribute '#{attribute}'",
               force_color: :red
            false
        end
      end

      # Set an attribute value for a given {Story::Screen}
      def set_screen_value( screen, attribute )
        case attribute.to_sym
          when :screen_name
            screen.name
          else
            lp "ValueMapper: cannot change attribute '#{attribute}' on #{screen.path}",
               force_color: :red
        end
      end

      # Set an attribute value for a given {Story::object}
      def set_object_value( object, attribute, value )
        case attribute.to_sym
          when :object_name
            object.name = value.to_s
          when :object_content
            object.content = value.to_s
          # next is object attributes
          when :'object_attribute:position_x'
            object.position = CGPoint.new(value.to_f, object.position.y)
          when :'object_attribute:position_y'
            object.position = CGPoint.new(object.position.x, value.to_f)
          when :'object_attribute:size_x'
            object.size = CGSize.new(value.to_f, object.size.height)
          when :'object_attribute:size_y'
            object.size = CGSize.new(object.size.width, value.to_f)
          when :'object_attribute:layer'
            object.layer = value.to_f
          when :'object_attribute:transparency'
            object.transparency = value.to_f
          else
            lp "ValueMapper: cannot #{object.path} has no attribute '#{attribute}'",
               force_color: :red
        end
      end
    end
  end
end

