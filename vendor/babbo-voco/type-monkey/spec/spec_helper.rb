require 'rspec'
require 'json'

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

end

$:.unshift( File.expand_path( File.join( Dir.pwd, 'lib' ) ) )
