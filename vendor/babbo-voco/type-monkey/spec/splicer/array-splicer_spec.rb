require 'spec_helper'

require 'helpers/mock-schema'
require 'type-monkey/schema'
require 'type-monkey/splicer'

RSpec.describe 'TypeMonkey::Splicer::ArraySplicer', :splicer => true do

  before( :all ) do
    # setup a stash for our test data
    @test_data = {}
    Dir.glob( 'spec/data/splice-*.json' ) do |file|
      @test_data[File.basename( file, '.json' )] = JSON.parse( File.read( file ) )
    end

    @schema = TypeMonkey::Schema::parse( @test_data['splice-rules'] )
  end

  it 'can determine it\'s path inside an object tree' do
    root = TypeMonkey::Splicer::ArraySplicer.new( @schema, 'spec-array-root', nil, @test_data['splice-01-array_01']  )

    expect( root.path ).to eq( ':spec-array-root' )
  end

  it 'creates objects for it\'s elements' do
    root = TypeMonkey::Splicer::ArraySplicer.new( @schema, 'spec-array-root', nil, @test_data['splice-01-array_01']  )

    expect( root.items.count ).to eq( 3 )
    expect( root.items[0] ).to be_a( TypeMonkey::Splicer::CoreSplicer )
    expect( root.items[0].path ).to eq( ':spec-array-root.item-type[0]' )

    expect( root.items[1] ).to be_a( TypeMonkey::Splicer::CoreSplicer )
    expect( root.items[1].path ).to eq( ':spec-array-root.item-type[1]' )

    expect( root.items[2] ).to be_a( TypeMonkey::Splicer::CoreSplicer )
    expect( root.items[2].path ).to eq( ':spec-array-root.item-type[2]' )
  end

  it 'supports the extended __idx/__val notation' do
    root = TypeMonkey::Splicer::ArraySplicer.new( @schema, 'spec-array-root', nil, @test_data['splice-01-array_02']  )

    expect( root.items.count ).to eq( 3 )
    expect( root.items[0] ).to be_a( TypeMonkey::Splicer::CoreSplicer )
    expect( root.items[0].path ).to eq( ':spec-array-root.item-type[2]' )

    expect( root.items[1] ).to be_a( TypeMonkey::Splicer::CoreSplicer )
    expect( root.items[1].path ).to eq( ':spec-array-root.item-type[3]' )

    expect( root.items[2] ).to be_a( TypeMonkey::Splicer::CoreSplicer )
    expect( root.items[2].path ).to eq( ':spec-array-root.item-type[4]' )
  end
end

