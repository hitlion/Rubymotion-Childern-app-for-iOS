require 'spec_helper'
require 'type-monkey/splicer/ops'

module TypeMonkey::Splicer::Ops
RSpec.describe 'TypeMonkey::Splicer::Ops::LogicOp', :splicer => true, :ops => true do

  it 'requires at least two operators' do
    expect{ LogicOp.new( 'and' ) }.to raise_error( Error, 'Logic operations require at least two parameters.' )
  end

  it 'accepts the defined operators' do
    expect( LogicOp.new( 'and', nil, nil ) ).to be_a( LogicOp )
    expect( LogicOp.new( 'or' , nil, nil ) ).to be_a( LogicOp )
  end

  it 'rejects undefined operators' do
    expect{ LogicOp.new( 'not', nil, nil ) }.to raise_error( Error, "Undefined logic operation 'not'." )
  end

  context '.eval' do
    before do
      @op_true  = double( 'ValueOp "true" double' )
      @op_false = double( 'ValueOp "false" double' )
    end

    context 'as OR operator' do

      it 'is satisfied if one of the operators returns true' do
        expect( @op_true  ).to receive( :eval ).at_least( 3 ).times.and_return( true )
        expect( @op_false ).to receive( :eval ).at_least( 3 ).times.and_return( false )

        expect( LogicOp.new( 'or', @op_true , @op_true  ).eval( nil ) ).to eq( true  )
        expect( LogicOp.new( 'or', @op_true , @op_false ).eval( nil ) ).to eq( true  )
        expect( LogicOp.new( 'or', @op_false, @op_true  ).eval( nil ) ).to eq( true  )
        expect( LogicOp.new( 'or', @op_false, @op_false ).eval( nil ) ).to eq( false )
      end

      it 'shortcuts as soon as one operator returns true' do
        expect( @op_true  ).to receive( :eval ).exactly( 3 ).times.and_return( true )
        expect( @op_false ).to receive( :eval ).exactly( 3 ).times.and_return( false )

        expect( LogicOp.new( 'or', @op_true , @op_false ).eval( nil ) ).to eq( true )
        expect( LogicOp.new( 'or', @op_false, @op_true  ).eval( nil ) ).to eq( true )
        expect( LogicOp.new( 'or', @op_false, @op_false ).eval( nil ) ).to eq( false )
        expect( LogicOp.new( 'or', @op_true , @op_true  ).eval( nil ) ).to eq( true )
      end

      it 'evaluates all operations if required' do
        expect( @op_false ).to receive( :eval ).exactly( 7 ).times.and_return( false )
        expect( @op_true  ).to receive( :eval ).exactly( 1 ).times.and_return( true  )

        expect( LogicOp.new( 'or', @op_false, @op_false, @op_false, @op_false ).eval( nil ) ).to eq( false )
        expect( LogicOp.new( 'or', @op_false, @op_false, @op_false, @op_true  ).eval( nil ) ).to eq( true  )
      end
    end

    context 'as AND operator' do

      it 'is satisfied only if all of the operators return true' do
        expect( @op_true  ).to receive( :eval ).at_least( 3 ).times.and_return( true )
        expect( @op_false ).to receive( :eval ).at_least( 3 ).times.and_return( false )

        expect( LogicOp.new( 'and', @op_true , @op_true  ).eval( nil ) ).to eq( true  )
        expect( LogicOp.new( 'and', @op_true , @op_false ).eval( nil ) ).to eq( false )
        expect( LogicOp.new( 'and', @op_false, @op_true  ).eval( nil ) ).to eq( false )
        expect( LogicOp.new( 'and', @op_false, @op_false ).eval( nil ) ).to eq( false )
      end

      it 'shortcuts as soon as one operator returns true' do
        expect( @op_true  ).to receive( :eval ).exactly( 3 ).times.and_return( true )
        expect( @op_false ).to receive( :eval ).exactly( 3 ).times.and_return( false )

        expect( LogicOp.new( 'and', @op_true , @op_false ).eval( nil ) ).to eq( false )
        expect( LogicOp.new( 'and', @op_false, @op_true  ).eval( nil ) ).to eq( false )
        expect( LogicOp.new( 'and', @op_false, @op_false ).eval( nil ) ).to eq( false )
        expect( LogicOp.new( 'and', @op_true , @op_true  ).eval( nil ) ).to eq( true  )
      end

      it 'evaluates all operations if required' do
        expect( @op_false ).to receive( :eval ).exactly( 1 ).times.and_return( false )
        expect( @op_true  ).to receive( :eval ).exactly( 7 ).times.and_return( true  )

        expect( LogicOp.new( 'and', @op_true, @op_true, @op_true, @op_false ).eval( nil ) ).to eq( false )
        expect( LogicOp.new( 'and', @op_true, @op_true, @op_true, @op_true  ).eval( nil ) ).to eq( true  )
      end
    end
  end
end
end

