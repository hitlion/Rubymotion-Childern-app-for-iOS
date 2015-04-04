require 'spec_helper'

require 'helpers/mock-schema'
require 'type-monkey/wrapper'

RSpec.describe 'TypeMonkey::Wrapper::CoreType', :wrapper => true, :core => true do

  before( :all ) do
    @schema = MockSchema.new
  end

  it 'creates a thin wrapper around a JSON specification' do
    expect( type = TypeMonkey::Wrapper.register( @schema, 'spec-type-1', 'string', {} ) ).to be_a( TypeMonkey::Wrapper::CoreType )
    expect( type.type_name ).to eq( 'spec-type-1' )
    expect( type.type_class ).to eq( String )
  end

  it 'keeps track of the known wrappers' do
    expect( TypeMonkey::Wrapper.get( @schema, 'spec-type-1' ) ).to be_a( TypeMonkey::Wrapper::CoreType )

    error_msg = %q(Attempting to redefine type 'spec-type-1'.)
    expect {
      TypeMonkey::Wrapper.register( @schema, 'spec-type-1', 'float', {} )
    }.to raise_error( TypeMonkey::Wrapper::Error, error_msg )
  end

  it 'requires a known base type for new wrappers' do
    error_msg = %q(Undefined parent type 'missing' for 'spec-type-2'.)
    expect {
      TypeMonkey::Wrapper.register( @schema, 'spec-type-2', 'missing', {} )
    }.to raise_error( TypeMonkey::Wrapper::Error, error_msg )
  end
end

