require 'spec_helper'

require 'helpers/mock-schema'
require 'type-monkey/schema'
require 'type-monkey/splicer'

RSpec.describe 'TypeMonkey::Splicer', :splicer => true do

  before( :all ) do
    # setup a stash for our test data
    @test_data = {}
    Dir.glob( 'spec/data/splice-*.json' ) do |file|
      @test_data[File.basename( file, '.json' )] = JSON.parse( File.read( file ) )
    end

    @schema    = TypeMonkey::Schema::parse( @test_data['splice-rules'] )
  end

  context 'without rules' do
    before do
      @nop_rules = double( 'Rules nop double' )
    end

    it 'can splice two core types' do
      expect( @nop_rules ).to receive( :find ).once.and_return( :modified )
      # this needs to use @test_data[...][0] since JSON.parse refuses simple
      # 'false' and '[ false ]' is required..
      res = TypeMonkey::Splicer::splice( @schema, @nop_rules, 'spec-core-root',
                                         @test_data['splice-02-core-original'][0],
                                         @test_data['splice-02-core-modified'][0] )

      expect( res ).to eq( true )
    end

    it 'can splice two array types' do
      expect( @nop_rules ).to receive( :find ).exactly( 5 ).times.and_return( :modified )
      res = TypeMonkey::Splicer::splice( @schema, @nop_rules, 'spec-array-root',
                                         @test_data['splice-02-array-original'],
                                         @test_data['splice-02-array-modified'] )

      expect( res ).to eq( [ 1, 2, 3, 4, 5, 6 ] )
    end

    it 'can splice two object types' do
      expect( @nop_rules ).to receive( :find ).exactly( 7 ).times.and_return( :modified )
      res = TypeMonkey::Splicer::splice( @schema, @nop_rules, 'spec-object-root',
                                         @test_data['splice-02-object-original'],
                                         @test_data['splice-02-object-modified'] )

      expect( res ).to eq( { "core-prop" => true, "array-prop" => [ 2, 2, 2, 2 ] } )
    end
  end

  context 'with loaded rules (no __copy\'d items)' do
    before( :all ) do
      @rules = TypeMonkey::Splicer::parse( @test_data['splice-02-rules-splice'] )
    end

    it 'can splice two core types' do
      # this needs to use @test_data[...][0] since JSON.parse refuses simple
      # 'false' and '[ false ]' is required..
      res = TypeMonkey::Splicer::splice( @schema, @rules, 'spec-core-root',
                                         @test_data['splice-02-core-original'][0],
                                         @test_data['splice-02-core-modified'][0] )

      expect( res ).to eq( true )
    end

    it 'can splice two array types' do
      # splice rules state that items with index < 2 should stay original
      # while items with index > 2 should be modified
      # also the array itself is immutable and doesn't accept additional items
      res = TypeMonkey::Splicer::splice( @schema, @rules, 'spec-array-root',
                                         @test_data['splice-02-array-original'],
                                         @test_data['splice-02-array-modified'] )

      expect( res ).to eq( [ 1, 2, 3, 4 ] )
    end

    it 'can splice two object types' do
      res = TypeMonkey::Splicer::splice( @schema, @rules, 'spec-object-root',
                                         @test_data['splice-02-object-original'],
                                         @test_data['splice-02-object-modified'] )

      expect( res ).to eq( { "core-prop" => true, "array-prop" => [ 1, 2, 2, 1 ] } )
    end

  end

  context 'with loaded rules (using __copy\'d items)' do
    it 'can splice two array types while copying needed elements' do
      schema = TypeMonkey::Schema::parse( @test_data['splice-03-rules'] )
      rules  = TypeMonkey::Splicer::parse( @test_data['splice-03-rules-splice'] )

      # this is a little more tricky - splice-03-array-original defines
      # only one array element but splice-03-array-modified contains three.
      # Elements two and three have a '__copy' tag referencing original[0].
      res = TypeMonkey::Splicer::splice( schema, rules, 'spec-array-root',
                                         @test_data['splice-03-array-copyref-original'],
                                         @test_data['splice-03-array-copyref-modified'] )

      expect( res ).to eq(
        [
          { "foo" => 42, "bar" => 88, "baz" => 88 }, # foo changed by modified[0]
          { "foo" => 88, "bar" => 21, "baz" => 88 }, # bar changed by modified[1]
          { "foo" => 88, "bar" => 88, "baz" => 84 }  # baz changed by modified[2]
        ]
      )
    end
  end
end

