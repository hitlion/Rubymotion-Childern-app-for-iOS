require 'spec_helper'

require 'helpers/mock-schema'
require 'type-monkey/schema'
require 'type-monkey/splicer'

RSpec.describe 'TypeMonkey::Splicer::CoreSplicer', :splicer => true do

  before( :all ) do
    # setup a stash for our test data
    @test_data = {}
    Dir.glob( 'spec/data/splice-*.json' ) do |file|
      @test_data[File.basename( file, '.json' )] = JSON.parse( File.read( file ) )
    end

    @schema = TypeMonkey::Schema::parse( @test_data['splice-rules'] )
  end

  it 'can determine it\'s path inside an object tree' do
    root = TypeMonkey::Splicer::CoreSplicer.new( @schema, 'spec-core-root', nil, nil  )

    expect( root.path ).to eq( ':spec-core-root' )
  end
#
#  context '' do
#    it '' do
#    end
#  end
end

