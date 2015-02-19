$:.unshift( "#{Dir.pwd}/lib" )
require 'rspec'
require 'json'
require 'jstype/rule_parser'
require 'helpers/basic_type_spec_helper'

base_rules = JSON.parse( File.read( './spec/data/rules-base.json' ) )

describe RuleParser do
  before do
    BasicType.reset!
  end

  it 'is able to detect the type definitions from parsed JSON' do
    types = RuleParser.parse( base_rules ).types
    expect( types.count ).to eq( 25 )
    expect( types.map { |t| t.type_name } ).to match_array( %w(version object_id
                                                               media mutability
                                                               mergeability
                                                               processability
                                                               smil_array
                                                               smil_array_meta
                                                               smil_base
                                                               smil_body
                                                               smil_body::event
                                                               smil_document
                                                               smil_head
                                                               smil_level
                                                               smil_meta
                                                               smil_object
                                                               smil_object::attribute
                                                               smil_object::event
                                                               smil_property
                                                               smil_screen
                                                               smil_screen::event
                                                               smil_slot_entry
                                                               smil_slot_list
                                                               smil_slot_list::variable
                                                               smil_slot_list::variable_list) )
  end

  it 'assigns the defined constraints to the type definitions' do
    types = RuleParser.parse( base_rules ).types.map { |t| [ t.type_name, t ] }.to_h

    # check only the simple base types for now
    expect( types['version'].pattern ).to eq( /\d+(\.\d+)*/ )
    expect( types['version'].enum ).to be_empty
    expect( types['version'].range ).to contain_exactly( nil, nil )

    expect( types['object_id'].pattern ).to eq( /(:|\w+)/ )
    expect( types['object_id'].enum ).to be_empty
    expect( types['object_id'].range ).to contain_exactly( nil, nil )

    expect( types['mutability'].pattern ).to be_nil
    expect( types['mutability'].enum ).to contain_exactly( 'client_only',
                                                           'server_only',
                                                           'client_server',
                                                           'immutable',
                                                           'inherit' )
    expect( types['mutability'].range ).to contain_exactly( nil, nil )

    expect( types['media'].pattern ).to be_nil
    expect( types['media'].enum ).to contain_exactly( 'video', 'audio', 'image' )
    expect( types['media'].range ).to contain_exactly( nil, nil )

    expect( types['mergeability'].pattern ).to be_nil
    expect( types['mergeability'].enum ).to contain_exactly( 'keep_original',
                                                             'keep_modified',
                                                             'discard',
                                                             'inherit' )
    expect( types['mergeability'].range ).to contain_exactly( nil, nil )

    expect( types['processability'].pattern ).to be_nil
    expect( types['processability'].enum ).to contain_exactly( 'local', 'remote' )
    expect( types['processability'].range ).to contain_exactly( nil, nil )
  end

  it 'is able to detect the validation scope' do
    scope = RuleParser.parse( base_rules ).scope
    expect( scope ).to_not be_nil

    # fixme: technically these tests belong into ObjectValidator..
    expect( scope.validate( [{
                                'name' => 'head',
                                'parent' => ':',
                                'data_language' => 'chicken stew',
                                'data_language_version' => '1.0.2',
                                'template_id' => '1.0'
    }] ) ).to eq( true )

    expect( scope.validate( [{
                              'name' => 'head',
                              'parent' => ':',
                              'data_language' => 'chicken stew',
                              'data_language_version' => '1.0.2',
                              'template_id' => '1.0'
    }, {} ] ) ).to eq( false )

    expect( scope.result_errors.first[1].first ).to eq( 'Number of items exceeds the valid range of { 0, 1 }.' )
  end
end
