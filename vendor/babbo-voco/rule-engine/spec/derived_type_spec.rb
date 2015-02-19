$:.unshift( "#{Dir.pwd}/lib" )
require 'rspec'
require 'jstype/types/derived_type'

describe DerivedType do
  it 'should not allow creating direct instances' do
    expect { DerivedType.new( '', String ) }.to raise_error( NoMethodError )
  end

  it 'should provide a way to register new types' do
    expect( DerivedType.register_type( 'spec_type', 'string' ) ).to_not be_nil
  end

  it 'should prevent redefining existing types' do
    expect do
      DerivedType.register_type( 'spec_type', 'integer' )
    end.to raise_error( TypeError, "Attempting to redefine 'spec_type'." )
  end

  it 'should provide a way to lookup types by their name' do
    type = DerivedType.type_with_name( 'spec_type' )
    expect( type ).to_not be_nil
    expect( type.type_name ).to eq( 'spec_type' )
  end

  it 'should return a SimpleType for string, integer and float' do
    expect( DerivedType.type_with_name( 'string'  ) ).to_not be_nil
    expect( DerivedType.type_with_name( 'string'  ) ).to be_a(SimpleType)

    expect( DerivedType.type_with_name( 'integer' ) ).to_not be_nil
    expect( DerivedType.type_with_name( 'integer' ) ).to be_a(SimpleType)

    expect( DerivedType.type_with_name( 'float'   ) ).to_not be_nil
    expect( DerivedType.type_with_name( 'float'   ) ).to be_a(SimpleType)
  end

  it 'should return a CompoundType for object and array' do
    expect( DerivedType.type_with_name( 'array'   ) ).to_not be_nil
    expect( DerivedType.type_with_name( 'array'   ) ).to be_a(CompoundType)

    expect( DerivedType.type_with_name( 'object'  ) ).to_not be_nil
    expect( DerivedType.type_with_name( 'object'  ) ).to be_a(CompoundType)
  end

  it 'should map back to it\'s native ruby type based on it\'s foundation' do
    expect( DerivedType.type_with_name( 'spec_type'  ).type_class ).to be String
  end
end
