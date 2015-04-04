require 'spec_helper'

require 'helpers/mock-schema'
require 'type-monkey/wrapper'

RSpec.describe 'TypeMonkey::Wrapper::ArrayType', :wrapper => true, :array => true do

  before( :all ) do
    @schema = MockSchema.new
  end

  context 'for types based on array' do

    it 'handles external and inline item type definitions' do
      item_spec = {
        'type' => 'integer',
        'min'  => 42,
        'max'  => 42
      }

      array_spec_ext = {
        'type' => 'array',
        'items' => {
          'type' => 'spec-array-item-1', # referenced from the above
        }
      }

      array_spec_int = {
        'type' => 'array',
        'items' => {
          'type' => {
            'type' => 'object',          # should create spec-array-ext_item-type
            'properties' => {
              'prop-1' => {
                'type' => 'string',
                'pattern' => '^foo$'
              }
            }
          }
        }
      }

     TypeMonkey::Wrapper.register( @schema, 'spec-array-item-1', 'integer', item_spec )
     type_ext = TypeMonkey::Wrapper.register( @schema, 'spec-array-3', 'array', array_spec_ext )
     type_int = TypeMonkey::Wrapper.register( @schema, 'spec-array-4', 'array', array_spec_int )
     type_int_items = TypeMonkey::Wrapper.get( @schema, 'spec-array-4.item-type' )

     expect( type_ext ).to be_a( TypeMonkey::Wrapper::ArrayType )
     expect( type_int ).to be_a( TypeMonkey::Wrapper::ArrayType )
     expect( type_int_items ).to be_a( TypeMonkey::Wrapper::CoreType )
    end
  end
end

