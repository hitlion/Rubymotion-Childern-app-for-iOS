$:.unshift( "#{Dir.pwd}/lib" )
require 'rspec'
require 'jstype/object_validator'
require 'jstype/types/derived_type'

DerivedType.register_type( 'spec_version', 'string' ).tap do |type|
  type.pattern = /\d+(\.\d+)/
end

DerivedType.register_type( 'spec_version_array', 'array' ).tap do |type|
  type.item_type = 'spec_version'
end

describe ObjectValidator do

  it 'references a type to validate' do
    pv = ObjectValidator.new( 'spec_version validator', 'spec_version' )

    expect( pv.type ).to be_a DerivedSimpleType
    expect( pv.type.type_name ).to eq 'spec_version'
    expect( pv.type.type_class ).to be String

    pv = ObjectValidator.new( 'spec_version_array validator', 'spec_version_array' )

    expect( pv.type ).to be_a DerivedCompoundType
    expect( pv.type.type_name ).to eq 'spec_version_array'
    expect( pv.type.type_class ).to be Array
  end
end
