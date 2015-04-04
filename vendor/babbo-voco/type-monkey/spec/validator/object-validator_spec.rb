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

RSpec.describe 'TypeMonkey::Validator::ObjectValidator', :validator => true, :object => true do

  before( :all ) do
    @schema = MockSchema.new
  end

  context 'for types based on object' do
    it 'creates a validator for the type and for each property' do
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

      setup_derived_type( @schema, 'spec-object', 'object', type_spec )
      validator = TypeMonkey::Validator.register( @schema, 'spec-object' )

      validator_prop_1 = TypeMonkey::Validator.get( @schema, 'spec-object.spec-prop-1' ) 
      validator_prop_2 = TypeMonkey::Validator.get( @schema, 'spec-object.spec-prop-2' )
      validator_prop_3 = TypeMonkey::Validator.get( @schema, 'spec-object.spec-prop-2.spec-prop-3' )

      expect( validator ).to be_a( TypeMonkey::Validator::ObjectValidator )
      expect( validator_prop_1 ).to be_a( TypeMonkey::Validator::CoreValidator )
      expect( validator_prop_2 ).to be_a( TypeMonkey::Validator::ObjectValidator )
      expect( validator_prop_3 ).to be_a( TypeMonkey::Validator::CoreValidator )
    end

    it 'validates each property using the created property validator' do
      validator = TypeMonkey::Validator.get( @schema, 'spec-object' )

      valid_obj = {
        'spec-prop-1' => 'bar',
        'spec-prop-2' => {
          'spec-prop-3' => true
        }
      }
      invalid_prop_1 = {
        'spec-prop-1' => 'foo',
        'spec-prop-2' => {
          'spec-prop-3' => true
        }
      }
      error_msg_1 = %q(spec-object: on property 'spec-prop-1':
... spec-object.spec-prop-1: value 'foo' does not match pattern /^bar/.)

      invalid_prop_2 = {
        'spec-prop-1' => 'bar',
        'spec-prop-2' => 42
      }
      error_msg_2 = %q(spec-object: on property 'spec-prop-2':
... spec-object.spec-prop-2: type mismatch, expected Hash but got Fixnum.)

      invalid_prop_3 = {
        'spec-prop-1' => 'bar',
        'spec-prop-2' => {
          'spec-prop-3' => 42
        }
      }
      error_msg_3 = %q(spec-object: on property 'spec-prop-2':
... spec-object.spec-prop-2: on property 'spec-prop-3':
... spec-object.spec-prop-2.spec-prop-3: type mismatch, expected Boolean but got Fixnum.)

      expect( validator.validate( valid_obj ) ).to eq( true )
      expect{ validator.validate( invalid_prop_1 ) }.to raise_error( TypeMonkey::Validator::Error, error_msg_1 )
      expect{ validator.validate( invalid_prop_2 ) }.to raise_error( TypeMonkey::Validator::Error, error_msg_2 )
      expect{ validator.validate( invalid_prop_3 ) }.to raise_error( TypeMonkey::Validator::Error, error_msg_3 )
    end

    it 'detects missing properties' do
      validator = TypeMonkey::Validator.get( @schema, 'spec-object' )

      missing_prop_1 = {
        'spec-prop-2' => {
          'spec-prop-3' => true
        }
      }
      error_msg_1 = %q(spec-object: missing property 'spec-prop-1'.)

      missing_prop_2 = {
        'spec-prop-1' => 'bar',
      }
      error_msg_2 = %q(spec-object: missing property 'spec-prop-2'.)

      missing_prop_3 = {
        'spec-prop-1' => 'bar',
        'spec-prop-2' => {
        }
      }
      error_msg_3 = %q(spec-object: on property 'spec-prop-2':
... spec-object.spec-prop-2: missing property 'spec-prop-3'.)

      expect{ validator.validate( missing_prop_1 ) }.to raise_error( TypeMonkey::Validator::Error, error_msg_1 )
      expect{ validator.validate( missing_prop_2 ) }.to raise_error( TypeMonkey::Validator::Error, error_msg_2 )
      expect{ validator.validate( missing_prop_3 ) }.to raise_error( TypeMonkey::Validator::Error, error_msg_3 )
    end

    it 'detects unexpected properties' do
      validator = TypeMonkey::Validator.get( @schema, 'spec-object' )

      unexpected_prop_1 = {
        'spec-prop-1' => 'bar',
        'spec-prop-2' => {
          'spec-prop-3' => true
        },
        'spec-prop-4' => 'peekeboo'
      }
      error_msg_1 = %q(spec-object: unexpected property 'spec-prop-4'.)

      unexpected_prop_2 = {
        'spec-prop-1' => 'bar',
        'spec-prop-2' => {
          'spec-prop-3' => true,
          'spec-prop-4' => 'peekeboo'
        }
      }
      error_msg_2 = %q(spec-object: on property 'spec-prop-2':
... spec-object.spec-prop-2: unexpected property 'spec-prop-4'.)

      expect{ validator.validate( unexpected_prop_1 ) }.to raise_error( TypeMonkey::Validator::Error, error_msg_1 )
      expect{ validator.validate( unexpected_prop_2 ) }.to raise_error( TypeMonkey::Validator::Error, error_msg_2 )
    end

    it 'injects default values for properties if required' do
      inject_obj_spec = {
        'type' => 'object',
        'properties' => {
          'prop-1' => {
            'type' => 'object',
            'properties' => {
              'sub-prop-1' => {
                'type' => 'integer'
              },
              'sub-prop-2' => {
                'type' => 'string'
              },
            },
            'default' => {
              'sub-prop-1' => 42,
              'sub-prop-2' => 'foo'
            }
          }
        }
      }

      sample_1_data = {
        'prop-1' => {
          'sub-prop-1' => 21,
          'sub-prop-2' => 'bar'
        }
      }

      sample_2_data = {
      }

      setup_derived_type( @schema, 'spec-inject-object', 'object', inject_obj_spec )
      validator = TypeMonkey::Validator.register( @schema, 'spec-inject-object' )

      expect( validator ).to be_a( TypeMonkey::Validator::ObjectValidator )

      # sample 1 should validate and come out unchanged
      expect( validator.validate( sample_1_data ) ).to eq( true )
      expect( sample_1_data['prop-1']['sub-prop-1'] ).to eq( 21 )
      expect( sample_1_data['prop-1']['sub-prop-2'] ).to eq( 'bar' )

      # sample 1 should validate but come out with added default properties
      expect( validator.validate( sample_2_data ) ).to eq( true )
      expect( sample_2_data['prop-1']['sub-prop-1'] ).to eq( 42 )
      expect( sample_2_data['prop-1']['sub-prop-2'] ).to eq( 'foo' )
    end

    it 'validates all properties, including those inherited' do
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
      setup_derived_type( @schema, 'spec-parent-object', 'object', parent_spec )
      setup_derived_type( @schema, 'spec-child-object', 'spec-parent-object', child_spec )

      validator = TypeMonkey::Validator.register( @schema, 'spec-child-object' )

      valid_obj = {
        'parent-prop' => 'foo',
        'child-prop' => 42
      }

      invalid_parent_prop = {
        'parent-prop' => 'bar',
        'child-prop' => 42
      }

      error_msg_parent_prop = %q(spec-child-object: on property 'parent-prop':
... spec-parent-object.parent-prop: value 'bar' does not match pattern /^foo$/.)

      invalid_child_prop = {
        'parent-prop' => 'foo',
        'child-prop' => 21
      }

      error_msg_child_prop = %q(spec-child-object: on property 'child-prop':
... spec-child-object.child-prop: value '21' is below the minimal value of '42'.)

      expect( validator.validate( valid_obj ) ).to eq( true )
      expect{ validator.validate( invalid_parent_prop ) }.to raise_error( TypeMonkey::Validator::Error, error_msg_parent_prop )
      expect{ validator.validate( invalid_child_prop ) }.to raise_error( TypeMonkey::Validator::Error, error_msg_child_prop )
    end

    it 'matches properties against expected values if present' do
      type_spec = {
        'type' => 'object',
        'properties' => {
          'exp-prop-1' => {
            'type' => 'integer'
          },
          'exp-prop-2' => {
            'type' => 'string'
          }
        },
        'expect' => {
          'exp-prop-1' => 42,
          'exp-prop-2' => 'foo'
        }
      }

      setup_derived_type( @schema, 'spec-expect-object', 'object', type_spec )
      validator = TypeMonkey::Validator.register( @schema, 'spec-expect-object' )

      valid_obj = {
        'exp-prop-1' => 42,
        'exp-prop-2' => 'foo'
      }

      # both of the following are valid according to the type spec
      # but violate one of the expeted property values
      invalid_prop_1 = {
        'exp-prop-1' => 21,
        'exp-prop-2' => 'foo'
      }

      invalid_prop_2 = {
        'exp-prop-1' => 42,
        'exp-prop-2' => 'bar'
      }

      error_msg_invalid_1 = %q(spec-expect-object: on property 'exp-prop-1':
... spec-expect-object: property 'exp-prop-1'(21) does not have the expected value '42'.)

      error_msg_invalid_2 = %q(spec-expect-object: on property 'exp-prop-2':
... spec-expect-object: property 'exp-prop-2'(bar) does not have the expected value 'foo'.)


      expect( validator.validate( valid_obj ) ).to eq( true )
      expect{ validator.validate( invalid_prop_1 ) }.to raise_error( TypeMonkey::Validator::Error, error_msg_invalid_1 )
      expect{ validator.validate( invalid_prop_2 ) }.to raise_error( TypeMonkey::Validator::Error, error_msg_invalid_2 )
    end
  end
end

