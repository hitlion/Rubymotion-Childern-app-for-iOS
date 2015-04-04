require 'spec_helper'

require 'helpers/mock-schema'
require 'type-monkey/wrapper'
require 'type-monkey/validator'

def setup_derived_type( schema, name, parent, spec )
  # Setup a derived type with a known parent and also
  # register a validator for that parent if it should be missing
  unless TypeMonkey::Validator.get( schema, parent )
    TypeMonkey::Validator.register( schema, parent )
  end
  TypeMonkey::Wrapper.register( schema, name, parent, spec )
end

RSpec.describe 'TypeMonkey::Validator::ArrayValidator', :validator => true, :array => true do

  before( :all ) do
    @schema = MockSchema.new
  end

  context 'for types based on array' do
#    it 'requires at least a valid "items" property for validator' do
#      expect{ setup_derived_type( @schema, 'spec-invalid-array', 'array', {} )
#
#      validator = TypeMonkey::Validator.register( @schema, 'spec-invalid-array' )
#
#      error_msg = %q(spec-invalid-array:
#... array: incomplete type specification (no 'items' property defined).)
#
#      expect( validator ).to be_a( TypeMonkey::Validator::ArrayValidator )
#      expect{ validator.validate( [] ) }.to raise_error( TypeMonkey::Validator::Error, error_msg )
#    end

    it 'recognizes and validates the "min_items" and "max_items" properties' do
      type_spec = {
        'type' => 'array',
        'items' => {
          'type'      => 'integer',
          'min_items' => 1,
          'max_items' => 3
        }
      }

      error_min_count = %q(spec-array-1: wrong number of items(0) - expected at least 1.)
      error_max_count = %q(spec-array-1: wrong number of items(4) - expected at most 3.)

      setup_derived_type( @schema, 'spec-array-1', 'array', type_spec )
      validator = TypeMonkey::Validator.register( @schema, 'spec-array-1' )

      expect( validator ).to be_a( TypeMonkey::Validator::ArrayValidator )

      expect( validator.validate( [ 1 ] ) ).to be( true )
      expect( validator.validate( [ 1, 2 ] ) ).to be( true )
      expect( validator.validate( [ 1, 2, 3 ] ) ).to be( true )

      expect{ validator.validate( [ ] ) }.to raise_error( TypeMonkey::Validator::Error, error_min_count )
      expect{ validator.validate( [ 1, 2, 3, 4 ] ) }.to raise_error( TypeMonkey::Validator::Error, error_max_count )
    end

    it 'correctly validates all items in the array' do
      item_spec = {
        'type' => 'integer',
        'min'  => 42,
        'max'  => 42
      }

      array_spec = {
        'type' => 'array',
        'items' => {
          'type' => 'spec-array-item-1',
        }
      }

      error_msg = %q(spec-array-2: on item[%d]:
... spec-array-item-1: value '21' is below the minimal value of '42'.)

     setup_derived_type( @schema, 'spec-array-item-1', 'integer', item_spec )
     setup_derived_type( @schema, 'spec-array-2', 'array', array_spec )

     validator = TypeMonkey::Validator.register( @schema, 'spec-array-2' )

     expect( validator ).to be_a( TypeMonkey::Validator::ArrayValidator )
     expect( validator.validate( [ 42, 42, 42 ] ) ).to eq( true )
     expect{ validator.validate( [ 21, 42, 42 ] ) }.to raise_error( TypeMonkey::Validator::Error, error_msg % 0 )
     expect{ validator.validate( [ 42, 21, 42 ] ) }.to raise_error( TypeMonkey::Validator::Error, error_msg % 1 )
     expect{ validator.validate( [ 42, 42, 21 ] ) }.to raise_error( TypeMonkey::Validator::Error, error_msg % 2 )
    end

    it 'handles external and inline item type definitions' do
      array_spec_ext = {
        'type' => 'array',
        'items' => {
          'type' => 'spec-array-item-1', # referenced from the last test
        }
      }

      array_spec_int = {
        'type' => 'array',
        'items' => {
          'type' => {
            'type' => 'object',          # should create spec-array-ext.item-type
            'properties' => {
              'prop-1' => {
                'type' => 'string',
                'pattern' => '^foo$'
              }
            }
          }
        }
      }

     error_msg_int = %q(spec-array-3: on item[0]:
... spec-array-item-1: value '21' is below the minimal value of '42'.)

     error_msg_ext = %q(spec-array-4: on item[0]:
... spec-array-4.item-type: on property 'prop-1':
... spec-array-4.item-type.prop-1: value 'bar' does not match pattern /^foo$/.)

     setup_derived_type( @schema, 'spec-array-3', 'array', array_spec_ext )
     setup_derived_type( @schema, 'spec-array-4', 'array', array_spec_int )

     valid_ext = TypeMonkey::Validator.register( @schema, 'spec-array-3' )
     valid_int = TypeMonkey::Validator.register( @schema, 'spec-array-4' )
     valid_int_items = TypeMonkey::Validator.get( @schema, 'spec-array-4.item-type' )

     expect( valid_ext ).to be_a( TypeMonkey::Validator::ArrayValidator )
     expect( valid_ext.validate( [ 42 ] ) ).to eq( true )
     expect{ valid_ext.validate( [ 21 ] ) }.to raise_error( TypeMonkey::Validator::Error, error_msg_int )

     expect( valid_int ).to be_a( TypeMonkey::Validator::ArrayValidator )
     expect( valid_int_items ).to be_a( TypeMonkey::Validator::CoreValidator )

     expect( valid_int.validate( [ { 'prop-1' => 'foo' } ] ) ).to eq( true )
     expect{ valid_int.validate( [ { 'prop-1' => 'bar' } ] ) }.to raise_error( TypeMonkey::Validator::Error, error_msg_ext )
    end
  end
end

