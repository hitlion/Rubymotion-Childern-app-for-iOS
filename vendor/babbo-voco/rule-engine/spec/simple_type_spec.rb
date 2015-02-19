$:.unshift( "#{Dir.pwd}/lib" )
require 'rspec'
require 'jstype/types/simple_type'

describe SimpleType do
  it 'should not allow creating direct instances' do
    expect { SimpleType.new( '' ) }.to raise_error( NoMethodError )
  end

  it 'should provide a way to register new types' do
    expect( SimpleType.register_type( 'spec_type', NilClass, false, false, false ) ).to_not be_nil
  end

  it 'should prevent redefining existing types' do
    expect do
      SimpleType.register_type( 'spec_type', NilClass, false, false, false )
    end.to raise_error( BasicType::TypeError, "Attempting to redefine 'spec_type'." )
  end

  it 'should provide a way to lookup types by their name' do
    type = SimpleType.type_with_name( 'spec_type' )
    expect( type ).to_not be_nil
    expect( type.type_name ).to eq( 'spec_type' )
  end

  it 'should define base types for string, integer and float' do
    expect( SimpleType.type_with_name( 'string'  ) ).to_not be_nil
    expect( SimpleType.type_with_name( 'integer' ) ).to_not be_nil
    expect( SimpleType.type_with_name( 'float'   ) ).to_not be_nil
  end

  it 'should map back to it\'s native ruby type' do
    expect( SimpleType.type_with_name( 'string'  ).type_class ).to be String
    expect( SimpleType.type_with_name( 'integer' ).type_class ).to be Fixnum
    expect( SimpleType.type_with_name( 'float'   ).type_class ).to be Float
  end

  it 'should provide a way to validate types using a pattern' do
    string = SimpleType.type_with_name( 'string' )

    expect( string.pattern ).to be_nil

    string.pattern = 'fo+'
    expect( string.pattern ).to eq( Regexp.new( 'fo+' ) )
    expect( string.validate( 'bar' ).valid ).to be false
    expect( string.validate( 'foo' ).valid ).to be true
    expect( string.validate( 'foobar' ).valid ).to be true

    string.pattern = nil
    expect( string.pattern ).to be_nil

    expect { string.pattern = '(invalid' }.to raise_error( BasicType::TypeError )
  end

  it 'should provide a way to validate types using an enumeration' do
    string = SimpleType.type_with_name( 'string' )

    expect( string.enum ).to match_array( [] )

    string.enum = %w(foo bar)
    expect( string.enum ).to contain_exactly( 'foo', 'bar' )
    expect( string.validate( 'foo' ).valid ).to be true
    expect( string.validate( 'bar' ).valid ).to be true
    expect( string.validate( 'baz' ).valid ).to be false
    expect( string.validate( 'cux' ).valid ).to be false

    string.enum = []
    expect( string.enum ).to match_array( [] )

    expect { string.enum = [ 1, 'foo' ] }.to raise_error( BasicType::TypeError )
  end

  it 'should provide a way to validate types using a range' do
    integer = SimpleType.type_with_name( 'integer' )

    expect( integer.range ).to match_array( [ nil, nil ] )
    expect( integer.validate( 42 ).valid ).to be true
    expect( integer.validate( 'bla' ).valid ).to be false

    integer.range_min = 5
    expect( integer.range ).to match_array( [ 5, nil ] )

    expect( integer.validate( 42 ).valid ).to be true
    expect( integer.validate( 5  ).valid ).to be true
    expect( integer.validate( 4  ).valid ).to be false

    integer.range_min = nil
    expect( integer.range ).to match_array( [ nil, nil ] )

    integer.range_max = 5
    expect( integer.range ).to match_array( [ nil, 5 ] )

    expect( integer.validate( 42 ).valid ).to be false
    expect( integer.validate( 5  ).valid ).to be true
    expect( integer.validate( 4  ).valid ).to be true

    integer.range_max = nil
    expect( integer.range ).to match_array( [ nil, nil ] )

    integer.range_min = 5
    integer.range_max = 6
    expect( integer.range ).to match_array( [ 5, 6 ] )
    expect( integer.validate( 42 ).valid ).to be false
    expect( integer.validate( 6  ).valid ).to be true
    expect( integer.validate( 5  ).valid ).to be true
    expect( integer.validate( 4  ).valid ).to be false

    expect do
      integer.range_min = 7
    end.to raise_error( BasicType::TypeError, 'range( 7 ) - min must be smaller than max.' )

    expect do
      integer.range_max = 4
    end.to raise_error( BasicType::TypeError, 'range( 4 ) - max must be larger than min.' )

    integer.range_min = integer.range_max = nil
    expect( integer.range ).to match_array( [ nil, nil ] )
  end
end
