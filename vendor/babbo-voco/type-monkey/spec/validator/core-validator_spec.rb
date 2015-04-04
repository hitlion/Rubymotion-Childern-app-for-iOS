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

RSpec.describe 'TypeMonkey::Validator::CoreValidator', :validator => true, :core => true do

  before( :all ) do
    @schema = MockSchema.new
  end

  context 'for a first-level type' do # anything based on string/integer/float etc.
    it 'checks values against the type class' do
      type      = TypeMonkey::Wrapper.get( @schema, 'string' )
      validator = TypeMonkey::Validator::CoreValidator.new( @schema, type )

      error_msg = %q(string: type mismatch, expected String but got Fixnum.)

      expect( validator.validate( 'test' ) ).to eq( true )
      expect{ validator.validate( 42 ) }.to raise_error( TypeMonkey::Validator::Error, error_msg )
    end

    it 'accepts a nil-value if a default was provided' do
      type      = TypeMonkey::Wrapper.register( @schema, 'spec-default-string', 'string', { 'default' => 'test' } )
      validator = TypeMonkey::Validator::CoreValidator.new( @schema, type )

      expect( validator.validate( nil ) ).to eq( true )
    end

    it 'rejects a nil-value if no default was provided' do
      type      = TypeMonkey::Wrapper.get( @schema, 'string' )
      validator = TypeMonkey::Validator::CoreValidator.new( @schema, type )

      error_msg = %q(string: 'null' is not a valid value and no default was provided.)

      expect{ validator.validate( nil ) }.to raise_error( TypeMonkey::Validator::Error, error_msg )
    end

    it 'is able to validate strings against a pattern' do
      type      = TypeMonkey::Wrapper.register( @schema, 'spec-pattern-string', 'string', { 'pattern' => '^foo' } )
      validator = TypeMonkey::Validator::CoreValidator.new( @schema, type )

      error_msg = %q(spec-pattern-string: value '%s' does not match pattern /^foo/.)

      expect( validator.validate( 'foo' ) ).to eq( true )
      expect( validator.validate( 'foobar' ) ).to eq( true )
      expect{ validator.validate( 'bar' ) }.to raise_error( TypeMonkey::Validator::Error, error_msg % 'bar' )
      expect{ validator.validate( 'barfoo' ) }.to raise_error( TypeMonkey::Validator::Error, error_msg % 'barfoo' )
    end

    it 'is able to validate strings against an enumeration' do
      type      = TypeMonkey::Wrapper.register( @schema, 'spec-enum-string', 'string', { 'enum' => %w(foo bar) } )
      validator = TypeMonkey::Validator::CoreValidator.new( @schema, type )

      error_msg = %q(spec-enum-string: value '%s' is not a member of ["foo", "bar"].)

      expect( validator.validate( 'foo' ) ).to eq( true )
      expect( validator.validate( 'bar' ) ).to eq( true )
      expect{ validator.validate( 'baz' ) }.to raise_error( TypeMonkey::Validator::Error, error_msg % 'baz' )
      expect{ validator.validate( 'cux' ) }.to raise_error( TypeMonkey::Validator::Error, error_msg % 'cux' )
    end

    it 'is able to validate integers against a range' do
      type      = TypeMonkey::Wrapper.register( @schema, 'spec-range-int', 'integer', { 'min' => 1, 'max' => 2 } )
      validator = TypeMonkey::Validator::CoreValidator.new( @schema, type )

      expected_min_msg = %q(spec-range-int: value '0' is below the minimal value of '1'.)
      expected_max_msg = %q(spec-range-int: value '3' is above the maximal value of '2'.)

      expect{ validator.validate( 0 ) }.to raise_error( TypeMonkey::Validator::Error, expected_min_msg )
      expect( validator.validate( 1 ) ).to eq( true )
      expect( validator.validate( 2 ) ).to eq( true )
      expect{ validator.validate( 3 ) }.to raise_error( TypeMonkey::Validator::Error, expected_max_msg )
    end

    it 'is able to validate integers against an enumeration' do
      type      = TypeMonkey::Wrapper.register( @schema, 'spec-enum-int', 'integer', { 'enum' => [ 1, 2 ] } )
      validator = TypeMonkey::Validator::CoreValidator.new( @schema, type )
      error_msg = %q(spec-enum-int: value '%d' is not a member of [1, 2].)

      expect( validator.validate( 1 ) ).to eq( true )
      expect( validator.validate( 2 ) ).to eq( true )
      expect{ validator.validate( 3 ) }.to raise_error( TypeMonkey::Validator::Error, error_msg % 3 )
      expect{ validator.validate( 4 ) }.to raise_error( TypeMonkey::Validator::Error, error_msg % 4 )
    end
  end

  context 'for a second-level type' do # anything based on a first-level type
    # mainly tests for inheritance and propper resolving of inherited constraints
    it 'is still able to validate against an inherited pattern' do
      type      = setup_derived_type( @schema, 'spec-derived-pattern-string', 'spec-pattern-string', {} )
      validator = TypeMonkey::Validator::CoreValidator.new( @schema, type )

      # spec-derived-pattern-string has no 'pattern' property of it's own but should still pass
      # all the tests that pass for spec-pattern-string
      error_msg = %q(spec-pattern-string: value '%s' does not match pattern /^foo/.)

      expect( validator.validate( 'foo' ) ).to eq( true )
      expect( validator.validate( 'foobar' ) ).to eq( true )
      expect{ validator.validate( 'bar' ) }.to raise_error( TypeMonkey::Validator::Error, error_msg % 'bar' )
      expect{ validator.validate( 'barfoo' ) }.to raise_error( TypeMonkey::Validator::Error, error_msg % 'barfoo' )
    end

    it 'is still able to validate against an inherited enumeration' do
      type      = setup_derived_type( @schema, 'spec-derived-enum-string', 'spec-enum-string', {} )
      validator = TypeMonkey::Validator::CoreValidator.new( @schema, type )

      error_msg = %q(spec-enum-string: value '%s' is not a member of ["foo", "bar"].)

      expect( validator.validate( 'foo' ) ).to eq( true )
      expect( validator.validate( 'bar' ) ).to eq( true )
      expect{ validator.validate( 'baz' ) }.to raise_error( TypeMonkey::Validator::Error, error_msg % 'baz' )
      expect{ validator.validate( 'cux' ) }.to raise_error( TypeMonkey::Validator::Error, error_msg % 'cux' )
    end

    it 'is still able to validate against an inherited range' do
      type      = setup_derived_type( @schema, 'spec-derived-range-int', 'spec-range-int', {} )
      validator = TypeMonkey::Validator::CoreValidator.new( @schema, type )

      expected_min_msg = %q(spec-range-int: value '0' is below the minimal value of '1'.)
      expected_max_msg = %q(spec-range-int: value '3' is above the maximal value of '2'.)

      expect{ validator.validate( 0 ) }.to raise_error( TypeMonkey::Validator::Error, expected_min_msg )
      expect( validator.validate( 1 ) ).to eq( true )
      expect( validator.validate( 2 ) ).to eq( true )
      expect{ validator.validate( 3 ) }.to raise_error( TypeMonkey::Validator::Error, expected_max_msg )
    end

    it 'prefers it\'s own definition over the inherited' do
      # override the inherited min/max property defining our own
      # caveat: this will always override the *whole range* not just parts of it
      type      = setup_derived_type( @schema, 'spec-derived-range-int2', 'spec-range-int', { 'min' => 1, 'max' => 3 } )
      validator = TypeMonkey::Validator::CoreValidator.new( @schema, type )

      # also note that the error message contains the derived types name, not the parent's
      expected_min_msg = %q(spec-derived-range-int2: value '0' is below the minimal value of '1'.)
      expected_max_msg = %q(spec-derived-range-int2: value '4' is above the maximal value of '3'.)

      expect{ validator.validate( 0 ) }.to raise_error( TypeMonkey::Validator::Error, expected_min_msg )
      expect( validator.validate( 1 ) ).to eq( true )
      expect( validator.validate( 2 ) ).to eq( true )
      expect( validator.validate( 3 ) ).to eq( true )
      expect{ validator.validate( 4 ) }.to raise_error( TypeMonkey::Validator::Error, expected_max_msg )
    end
  end
end

