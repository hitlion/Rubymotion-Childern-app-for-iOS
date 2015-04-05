# noinspection RubyResolve
unless defined? Motion::Project::App
  raise 'This file must be required within a RubyMotion project Rakefile.'
end

lib_dir_path = File.dirname( File.expand_path( __FILE__ ) )

# noinspection RubyResolve
Motion::Project::App.setup do |app|
  gem_files = Dir.glob( File.join( lib_dir_path, 'type-monkey/**/*.rb' ) )
  #app.files.unshift( gem_files.select { |f| !( f =~ /validator\/core.rb/ ) } ).flatten!
  #app.files.unshift( gem_files.select { |f| f =~ /validator\/core.rb/ } ).flatten!
  app.files.unshift( gem_files )
end
