require 'spec_helper'

require 'helpers/mock-schema'
require 'type-monkey/schema'
require 'type-monkey/splicer'

RSpec.describe 'TypeMonkey::Splicer::ObjectSplicer', :splicer => true do

  before( :all ) do
    # setup a stash for our test data
    @test_data = {}
    Dir.glob( 'spec/data/splice-*.json' ) do |file|
      @test_data[File.basename( file, '.json' )] = JSON.parse( File.read( file ) )
    end

    @schema = TypeMonkey::Schema::parse( @test_data['splice-rules'] )
  end

  it 'can determine it\'s path inside an object tree' do
    root = TypeMonkey::Splicer::ObjectSplicer.new( @schema, 'spec-object-root', nil, @test_data['splice-01-object']  )

    expect( root.path ).to eq( ':spec-object-root' )
  end

  it 'creates splicer objects for it\'s properties' do
    root = TypeMonkey::Splicer::ObjectSplicer.new( @schema, 'spec-object-root', nil, @test_data['splice-01-object']  )

    expect( root.properties.keys ).to contain_exactly( '$index', 'core-prop', 'array-prop' )
    expect( root.props.keys ).to contain_exactly( 'core-prop', 'array-prop' )
    expect( root.props['core-prop'] ).to be_a( TypeMonkey::Splicer::CoreSplicer )
    expect( root.props['array-prop'] ).to be_a( TypeMonkey::Splicer::ArraySplicer )
  end
end

