require 'spec_helper'

require 'helpers/mock-schema'
require 'type-monkey/wrapper'

RSpec.describe 'TypeMonkey::Wrapper::Object', :wrapper => true, :object => true do

  before( :all ) do
    @schema = MockSchema.new
  end

  context 'for types based on object' do
    it 'creates a wrapper for the type and for each property' do
      type_spec = {
        'type'       => 'object',
        'properties' => {
          'spec-prop-1' => {
            'type'    => 'string',
            'pattern' => '^bar'
          },
          # make this test a little more interesting by defining a
          # completely new object based type as a nested property
          'spec-prop-2' => {
            'type'       => 'object',
            'properties' => {
              'spec-prop-3' => {
                'type' => 'boolean'
              }
            }
          }
        }
      }

      type = TypeMonkey::Wrapper.register( @schema, 'spec-object', 'object', type_spec )

      expect( type ).to be_a( TypeMonkey::Wrapper::ObjectType )
      expect( TypeMonkey::Wrapper.get( @schema, 'spec-object.spec-prop-1' ) ).to be_a( TypeMonkey::Wrapper::CoreType )
      expect( TypeMonkey::Wrapper.get( @schema, 'spec-object.spec-prop-2' ) ).to be_a( TypeMonkey::Wrapper::ObjectType )
      expect( TypeMonkey::Wrapper.get( @schema, 'spec-object.spec-prop-2.spec-prop-3' ) ).to be_a( TypeMonkey::Wrapper::CoreType )
    end

    it 'inherits properties from it\'s parent' do
      parent_spec = {
        'type' => 'object',
        'properties' => {
          'parent-prop' => {
            'type'    => 'string',
            'pattern' => '^foo$'
          }
        }
      }

      child_spec = {
        'type' => 'spec-parent-object',
        'properties' => {
          'child-prop' => {
            'type' => 'integer',
            'min'  => 42,
            'max'  => 42
          }
        }
      }
      TypeMonkey::Wrapper.register( @schema, 'spec-parent-object', 'object', parent_spec )
      type = TypeMonkey::Wrapper.register( @schema, 'spec-child-object', 'spec-parent-object', child_spec )

      expect( type ).to be_a( TypeMonkey::Wrapper::ObjectType )
      expect( type.properties.keys ).to match_array( %w( parent-prop child-prop ) )
    end
  end
end

