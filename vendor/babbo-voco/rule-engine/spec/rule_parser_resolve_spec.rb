$:.unshift( "#{Dir.pwd}/lib" )
require 'rspec'
require 'json'
require 'jstype/rule_parser'
require 'helpers/basic_type_spec_helper'

describe RuleParser do
#  context 'for simply recursive partially fractalized types' do
#    before do
#      BasicType.reset!
#      @base_rules = JSON.parse( File.read( File.join( './spec/data/forward_reference-rules.json' ) ) )
#      @test_data = JSON.parse( File.read( File.join( './spec/data/forward_reference.json' ) ) )
#    end
#
#    it 'does proper resolution of ForwardReference types..' do
#      res = RuleParser.parse( @base_rules )
#      valid = res.scope.validate( @test_data )
#      res.scope.result_errors.each do |error|
#        puts "#{error[0]}:"
#        error[1].each { |e| puts "- #{e}" }
#      end
#
#      expect( valid ).to be( true )
#    end
#  end
#
  context 'for Babbo SMIL' do
    before do
      BasicType.reset!
      @base_rules = JSON.parse( File.read( File.join( './rules-base.json' ) ) )
      @test_data = JSON.parse( File.read( File.join( './control.json' ) ) )
    end

    it 'does proper resolution of ForwardReference types..' do
      res = RuleParser.parse( @base_rules )
      valid = res.scope.validate( @test_data )
      res.scope.result_errors.each do |error|
        puts "#{error[0]}:"
        error[1].each { |e| puts "- #{e}" }
      end

      expect( valid ).to be( true )
    end
  end
end

