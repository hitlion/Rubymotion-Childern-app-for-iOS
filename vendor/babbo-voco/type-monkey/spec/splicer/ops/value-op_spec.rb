require 'spec_helper'
require 'type-monkey/splicer/ops'

module TypeMonkey::Splicer::Ops
RSpec.describe 'TypeMonkey::Splicer::Ops::ValueOp', :splicer => true, :ops => true do

  before( :all ) do
  end

  it 'accepts the defined operators' do
    expect( ValueOp.new( '==', nil, nil ) ).to_not be( nil )
    expect( ValueOp.new( '~=', nil, nil ) ).to_not be( nil )
    expect( ValueOp.new( '/=', nil, nil ) ).to_not be( nil )
    expect( ValueOp.new( '<=', nil, nil ) ).to_not be( nil )
    expect( ValueOp.new( '>=', nil, nil ) ).to_not be( nil )
    expect( ValueOp.new( '<',  nil, nil ) ).to_not be( nil )
    expect( ValueOp.new( '>',  nil, nil ) ).to_not be( nil )
  end

  it 'rejects undefined operators' do
    error_msg = %q(Undefined value operation '<>'.)
    expect{ ValueOp.new( '<>',  nil, nil ) }.to raise_error( TypeMonkey::Splicer::Ops::Error, error_msg )
  end

  context '.eval' do
    context 'comparing against a boolean' do
      before do
        @obj = double( 'CoreSplicer double' )
      end

      it 'accepts only "==" and "/="' do
        allow( @obj ).to receive( :properties ).exactly( 2 ).times.and_return( { '$value' => true } )

        error_msg = %q(Unsupported value operation '%s' on type 'TrueClass'.)

        expect( ValueOp.new( '==', '$value', true ).eval( @obj ) ).to eq( true )
        expect( ValueOp.new( '/=', '$value', true ).eval( @obj ) ).to eq( false )
        expect{ ValueOp.new( '~=', '$value', true ).eval( @obj ) }.to raise_error( Error, error_msg % '~=' )
        expect{ ValueOp.new( '<=', '$value', true ).eval( @obj ) }.to raise_error( Error, error_msg % '<=' )
        expect{ ValueOp.new( '>=', '$value', true ).eval( @obj ) }.to raise_error( Error, error_msg % '>=' )
        expect{ ValueOp.new( '<',  '$value', true ).eval( @obj ) }.to raise_error( Error, error_msg % '<'  )
        expect{ ValueOp.new( '>',  '$value', true ).eval( @obj ) }.to raise_error( Error, error_msg % '>'  )

      end

      it 'detects equal booleans using "=="' do
        op = TypeMonkey::Splicer::Ops::ValueOp.new( '==', '$value', true )

        allow( @obj ).to receive( :properties ).twice.and_return( { '$value' => true }, { '$value' => false } )

        expect( op.eval( @obj ) ).to eq( true )
        expect( op.eval( @obj ) ).to eq( false )
      end

      it 'detects different booleans using "/="' do
        op = TypeMonkey::Splicer::Ops::ValueOp.new( '/=', '$value', true )

        allow( @obj ).to receive( :properties ).twice.and_return( { '$value' => true }, { '$value' => false } )

        expect( op.eval( @obj ) ).to eq( false )
        expect( op.eval( @obj ) ).to eq( true )
      end
    end

    context 'comparing against a string' do
      before do
        @obj = double( 'CoreSplicer double' )
      end

      it 'accepts only "==", "/=" and "~="' do
        allow( @obj ).to receive( :properties ).exactly( 3 ).times.and_return( { '$value' => 'foo' } )

        error_msg = %q(Unsupported value operation '%s' on type 'String'.)

        expect( ValueOp.new( '==', '$value', 'foo' ).eval( @obj ) ).to eq( true )
        expect( ValueOp.new( '~=', '$value', 'foo' ).eval( @obj ) ).to eq( true )
        expect( ValueOp.new( '/=', '$value', 'foo' ).eval( @obj ) ).to eq( false )
        expect{ ValueOp.new( '<=', '$value', 'foo' ).eval( @obj ) }.to raise_error( Error, error_msg % '<=' )
        expect{ ValueOp.new( '>=', '$value', 'foo' ).eval( @obj ) }.to raise_error( Error, error_msg % '>=' )
        expect{ ValueOp.new( '<',  '$value', 'foo' ).eval( @obj ) }.to raise_error( Error, error_msg % '<'  )
        expect{ ValueOp.new( '>',  '$value', 'foo' ).eval( @obj ) }.to raise_error( Error, error_msg % '>'  )

      end

      it 'detects equal strings using "=="' do
        op = TypeMonkey::Splicer::Ops::ValueOp.new( '==', '$value', 'foo' )

        allow( @obj ).to receive( :properties ).twice.and_return( { '$value' => 'foo' }, { '$value' => 'bar' } )

        expect( op.eval( @obj ) ).to eq( true )
        expect( op.eval( @obj ) ).to eq( false )
      end

      it 'detects different strings using "/="' do
        op = TypeMonkey::Splicer::Ops::ValueOp.new( '/=', '$value', 'foo' )

        allow( @obj ).to receive( :properties ).twice.and_return( { '$value' => 'foo' }, { '$value' => 'bar' } )

        expect( op.eval( @obj ) ).to eq( false )
        expect( op.eval( @obj ) ).to eq( true )
      end

      it 'detects matching expressions using "~="' do
        op = TypeMonkey::Splicer::Ops::ValueOp.new( '~=', '$value', '^fo+$' )

        allow( @obj ).to receive( :properties ).twice.and_return( { '$value' => 'foo' }, { '$value' => 'bar' } )

        expect( op.eval( @obj ) ).to eq( true )
        expect( op.eval( @obj ) ).to eq( false )
      end
    end

    context 'comparing against an integer' do
      before do
        @obj = double( 'CoreSplicer double' )
      end

      it 'accepts only "==", "/=", "<=", ">=", "<" and ">"' do
        allow( @obj ).to receive( :properties ).exactly( 6 ).times.and_return( { '$value' => 42 } )

        error_msg = %q(Unsupported value operation '%s' on type 'Fixnum'.)

        expect( ValueOp.new( '==', '$value', 42 ).eval( @obj ) ).to eq( true )
        expect( ValueOp.new( '/=', '$value', 42 ).eval( @obj ) ).to eq( false )
        expect( ValueOp.new( '<=', '$value', 42 ).eval( @obj ) ).to eq( true )
        expect( ValueOp.new( '>=', '$value', 42 ).eval( @obj ) ).to eq( true )
        expect( ValueOp.new( '<',  '$value', 42 ).eval( @obj ) ).to eq( false )
        expect( ValueOp.new( '>',  '$value', 42 ).eval( @obj ) ).to eq( false )
        expect{ ValueOp.new( '~=', '$value', 42 ).eval( @obj ) }.to raise_error( Error, error_msg % '~=' )
      end

      it 'detects equal numbers using "=="' do
        op = TypeMonkey::Splicer::Ops::ValueOp.new( '==', '$value', 42 )

        allow( @obj ).to receive( :properties ).twice.and_return( { '$value' => 42 }, { '$value' => 21 } )

        expect( op.eval( @obj ) ).to eq( true )
        expect( op.eval( @obj ) ).to eq( false )
      end

      it 'detects different numbers using "/="' do
        op = TypeMonkey::Splicer::Ops::ValueOp.new( '/=', '$value', 42 )

        allow( @obj ).to receive( :properties ).twice.and_return( { '$value' => 42 }, { '$value' => 21 } )

        expect( op.eval( @obj ) ).to eq( false )
        expect( op.eval( @obj ) ).to eq( true )
      end

      it 'detects smaller and equal numbers using "<="' do
        op = TypeMonkey::Splicer::Ops::ValueOp.new( '<=', '$value', 42 )

        allow( @obj ).to receive( :properties ).exactly( 3 ).times.and_return( { '$value' => 41 },
                                                                               { '$value' => 42 },
                                                                               { '$value' => 43 } )

        expect( op.eval( @obj ) ).to eq( true )
        expect( op.eval( @obj ) ).to eq( true )
        expect( op.eval( @obj ) ).to eq( false )
      end

      it 'detects equal and bigger numbers using "<="' do
        op = TypeMonkey::Splicer::Ops::ValueOp.new( '>=', '$value', 42 )

        allow( @obj ).to receive( :properties ).exactly( 3 ).times.and_return( { '$value' => 43 },
                                                                               { '$value' => 42 },
                                                                               { '$value' => 41 } )

        expect( op.eval( @obj ) ).to eq( true )
        expect( op.eval( @obj ) ).to eq( true )
        expect( op.eval( @obj ) ).to eq( false )
      end

      it 'detects smaller numbers using "<"' do
        op = TypeMonkey::Splicer::Ops::ValueOp.new( '<', '$value', 42 )

        allow( @obj ).to receive( :properties ).exactly( 3 ).times.and_return( { '$value' => 41 },
                                                                               { '$value' => 42 },
                                                                               { '$value' => 43 } )

        expect( op.eval( @obj ) ).to eq( true )
        expect( op.eval( @obj ) ).to eq( false )
        expect( op.eval( @obj ) ).to eq( false )
      end

      it 'detects bigger numbers using ">"' do
        op = TypeMonkey::Splicer::Ops::ValueOp.new( '>', '$value', 42 )

        allow( @obj ).to receive( :properties ).exactly( 3 ).times.and_return( { '$value' => 41 },
                                                                               { '$value' => 42 },
                                                                               { '$value' => 43 } )

        expect( op.eval( @obj ) ).to eq( false )
        expect( op.eval( @obj ) ).to eq( false )
        expect( op.eval( @obj ) ).to eq( true )
      end
    end

    context 'comparing against a float' do
      before do
        @obj = double( 'CoreSplicer double' )
      end

      it 'accepts only "==", "/=", "<=", ">=", "<" and ">"' do
        allow( @obj ).to receive( :properties ).exactly( 6 ).times.and_return( { '$value' => 42.0 } )

        error_msg = %q(Unsupported value operation '%s' on type 'Float'.)

        expect( ValueOp.new( '==', '$value', 42.0 ).eval( @obj ) ).to eq( true )
        expect( ValueOp.new( '/=', '$value', 42.0 ).eval( @obj ) ).to eq( false )
        expect( ValueOp.new( '<=', '$value', 42.0 ).eval( @obj ) ).to eq( true )
        expect( ValueOp.new( '>=', '$value', 42.0 ).eval( @obj ) ).to eq( true )
        expect( ValueOp.new( '<',  '$value', 42.0 ).eval( @obj ) ).to eq( false )
        expect( ValueOp.new( '>',  '$value', 42.0 ).eval( @obj ) ).to eq( false )
        expect{ ValueOp.new( '~=', '$value', 42.0 ).eval( @obj ) }.to raise_error( Error, error_msg % '~=' )
      end

      it 'detects equal numbers using "=="' do
        op = TypeMonkey::Splicer::Ops::ValueOp.new( '==', '$value', 42.0 )

        allow( @obj ).to receive( :properties ).twice.and_return( { '$value' => 42.0 }, { '$value' => 21 } )

        expect( op.eval( @obj ) ).to eq( true )
        expect( op.eval( @obj ) ).to eq( false )
      end

      it 'detects different numbers using "/="' do
        op = TypeMonkey::Splicer::Ops::ValueOp.new( '/=', '$value', 42.0 )

        allow( @obj ).to receive( :properties ).twice.and_return( { '$value' => 42.0 }, { '$value' => 21 } )

        expect( op.eval( @obj ) ).to eq( false )
        expect( op.eval( @obj ) ).to eq( true )
      end

      it 'detects smaller and equal numbers using "<="' do
        op = TypeMonkey::Splicer::Ops::ValueOp.new( '<=', '$value', 42.0 )

        allow( @obj ).to receive( :properties ).exactly( 3 ).times.and_return( { '$value' => 41.0 },
                                                                               { '$value' => 42.0 },
                                                                               { '$value' => 43.0 } )

        expect( op.eval( @obj ) ).to eq( true )
        expect( op.eval( @obj ) ).to eq( true )
        expect( op.eval( @obj ) ).to eq( false )
      end

      it 'detects equal and bigger numbers using "<="' do
        op = TypeMonkey::Splicer::Ops::ValueOp.new( '>=', '$value', 42.0 )

        allow( @obj ).to receive( :properties ).exactly( 3 ).times.and_return( { '$value' => 43.0 },
                                                                               { '$value' => 42.0 },
                                                                               { '$value' => 41.0 } )

        expect( op.eval( @obj ) ).to eq( true )
        expect( op.eval( @obj ) ).to eq( true )
        expect( op.eval( @obj ) ).to eq( false )
      end

      it 'detects smaller numbers using "<"' do
        op = TypeMonkey::Splicer::Ops::ValueOp.new( '<', '$value', 42.0 )

        allow( @obj ).to receive( :properties ).exactly( 3 ).times.and_return( { '$value' => 41.0 },
                                                                               { '$value' => 42.0 },
                                                                               { '$value' => 43.0 } )

        expect( op.eval( @obj ) ).to eq( true )
        expect( op.eval( @obj ) ).to eq( false )
        expect( op.eval( @obj ) ).to eq( false )
      end

      it 'detects bigger numbers using ">"' do
        op = TypeMonkey::Splicer::Ops::ValueOp.new( '>', '$value', 42.0 )

        allow( @obj ).to receive( :properties ).exactly( 3 ).times.and_return( { '$value' => 41.0 },
                                                                               { '$value' => 42.0 },
                                                                               { '$value' => 43.0 } )

        expect( op.eval( @obj ) ).to eq( false )
        expect( op.eval( @obj ) ).to eq( false )
        expect( op.eval( @obj ) ).to eq( true )
      end
    end
  end
end
end
