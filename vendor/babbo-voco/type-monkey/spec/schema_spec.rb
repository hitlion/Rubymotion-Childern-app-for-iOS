require 'spec_helper'
require 'type-monkey/schema'

RSpec.describe 'TypeMonkey::Schema', :schema => true do

  before( :all ) do
    # setup a stash for our test data
    @test_data = {}
    Dir.glob( 'spec/data/schema-parse-*.json' ) do |file|
      @test_data[File.basename( file, '.json' )] = JSON.parse( File.read( file ) )
    end

    @mock_register_simple = lambda { |s,tn,_,_| s.types ||= {}; s.types[tn] = {} }
    @mock_register_args   = [ instance_of( TypeMonkey::Schema ),
                              instance_of( String ),
                              instance_of( String ),
                              instance_of( Hash ) ]
  end

  it 'requires a schema to have a dictionary as toplevel object' do
    error_msg = %q(Expected a dictionary as JSON toplevel element.)

    expect( TypeMonkey::Schema.parse( {} ) ).to be_a( TypeMonkey::Schema )
    expect{ TypeMonkey::Schema.parse( [] ) }.to raise_error( TypeMonkey::Schema::Error, error_msg )
    expect{ TypeMonkey::Schema.parse( '' ) }.to raise_error( TypeMonkey::Schema::Error, error_msg )
    expect{ TypeMonkey::Schema.parse( 0  ) }.to raise_error( TypeMonkey::Schema::Error, error_msg )
    expect{ TypeMonkey::Schema.parse( nil ) }.to raise_error( TypeMonkey::Schema::Error, error_msg )
  end

  it 'creates type wrappers for all toplevel types in the schema' do

    expect( TypeMonkey::Wrapper ).to receive( :register ).with( *@mock_register_args ).exactly( 6 ).times( &@mock_register_simple )
    schema = TypeMonkey::Schema.parse( @test_data['schema-parse-01'] )

    expect( schema.types ).to have_key( 'schema-type-int' )
    expect( schema.types ).to have_key( 'schema-type-str' )
    expect( schema.types ).to have_key( 'schema-type-bool' )
    expect( schema.types ).to have_key( 'schema-type-float' )
    expect( schema.types ).to have_key( 'schema-type-obj' )
    expect( schema.types ).to have_key( 'schema-type-ary' )
  end

  it 'ignores any toplevel key/value pair that is not a type definition' do
    expect( TypeMonkey::Wrapper ).to receive( :register ).with( *@mock_register_args ).once( &@mock_register_simple )
    schema = TypeMonkey::Schema.parse( @test_data['schema-parse-02'] )

    expect( schema.types.keys ).to contain_exactly( 'schema-type-int' )
  end

  it 'requires type definitions to at least contain a "type" property' do
    error_msg = %q(Definition for type 'schema-type-invalid' has no 'type' attribute!)

    expect( TypeMonkey::Wrapper ).to receive( :register ).with( *@mock_register_args ).exactly( 0 ).times
    expect{ TypeMonkey::Schema.parse( @test_data['schema-parse-03'] ) }.to raise_error( TypeMonkey::Schema::Error, error_msg )
  end
end

