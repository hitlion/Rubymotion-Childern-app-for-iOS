module Story
  module Changelog
    # A collection of {Story::Changelog::Rule} instances
    class Ruleset
      attr_reader :rules

      # Create a new {Ruleset} from parsed +data+
      # @param [Array] data An array of rule definitions
      #   parsed from JSON or YAML.
      def initialize( data )
        @rules = []
        @cache = {}

        data = data || []
        data.each do |item|
          rule = Rule.new(Hash.symbolicate(item))
          @rules << rule if rule.valid?
        end
      end

      # Lookup the required action for a given story path.
      #
      # @param [StoryBundle] bundle the {StoryBundle} containing the
      #   objects which form +path+
      # @param [String] path A valid path inside story bundle
      # @return [Symbol] one of +:accept+ or +:reject+ depending on
      #   the required action.
      def action_for_path( bundle, path )
        return @cache[path] unless @cache[path].nil?

        mapper = ValueMapper.new(bundle)
        best_match = nil

        @cache[path] = :reject
        @rules.each do |rule|
          if rule.eval(mapper, path)
            if best_match.nil? or \
               rule.distance < best_match.distance or \
               ( rule.is_exact? and ! best_match.is_exact? )
              best_match = rule
            end
          end
        end
        @cache[path] = best_match.splice unless best_match.nil?
        @cache[path]
      end

      # Lookup the allowed actions for a given story path
      #
      # @param [StoryBundle] bundle the {StoryBundle} containing the
      #   object wich form +path+
      # @param [String] path A valid path inside the story bundle
      # @return [Hash<Symbol>] A hash with all editable parameters for
      #   the object at +path+
      def options_for_object( bundle, path )
        options = [
          :object_name,
          :object_content,
          :position_x,
          :position_y,
          :size_x,
          :size_y,
          :transparency,
          :layer
        ]
        available = {}

        return available unless /^:level\[\d+\]:screen\[\d+\]:object\[\d+\]$/.match(path)

        options.each do |key|
          if(key == :object_name || key == :object_content)
            p = "#{path}:#{key}"
          else
            p = "#{path}:object_attributes:#{key}"
          end

          if action_for_path(bundle, p) == :accept
            available[key] = true
          end
        end
        available
      end

      # Return all editable objects inside a given story screen
      #
      # @param [StoryBundle] bundle the {StoryBundle} containing the
      #   screen
      # @param [String] screen_path A valid path ending in a story screen.
      # @return [Hash<String, Hash<Symbol,TrueClass>] A hash of paths with each path
      #   representing an editable object along with which properties are
      #   actually editable.
      def editable_objects_for_screen( bundle, screen_path )
        return {} unless /^:level\[\d+\]:screen\[\d+\]$/.match( screen_path )
        screen = bundle.object_for_path( screen_path )
        return {} if screen.nil?

        res = {}
        screen.objects.each do |obj|
          options = options_for_object(bundle, obj.path)
          res[obj.path] = options unless options.empty?
        end

        res
      end

      def editable_screens
        screens = []

        @rules.each do |rule|
          if(rule.splice == :accept)
            parts = rule.path.split(":")
            path = ':' + parts[1] + ':' + parts[2]
            screens << path  unless(screens.include?(path))
          end
        end

        screens
      end
    end
  end
end

