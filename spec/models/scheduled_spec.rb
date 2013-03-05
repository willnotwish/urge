require 'spec_helper'

Logging.logger['simple'].tap {|logger| 
  logger.add_appenders 'colourful_stdout'
  logger.level = :info
}

# 
# 
# 
class Simple

  # By including the Urge module, we drag in all the class methods from that module
  include Urge
  
  attr_accessor :something_at
  attr_reader :actions, :logger
  
  def initialize( attrs = {} )
    self.something_at = attrs[:something_at]

    @logger = Logging.logger['simple']
    @actions = []
  end

  urge_schedule :something, :action => 'do_something'
  
  def do_something( options )
    @actions << :foo unless options[:dry_run]
    nil
  end
  
end

describe Urge do
  
  context "when applied to a simple, in memory object" do
    
    before(:each) do
      @object = Simple.new
    end
    
    it "should exist with no actions" do
      @object.should_not be_nil
      @object.actions.should be_empty
    end
    
    context "that is not scheduled" do
      
      context "when urged to do something" do

        before(:each) do
          @object.urge( :something )
        end

        it "should do nothing" do
          @object.actions.should be_empty
        end

      end
      
    end
    
    context "that has been scheduled to run 1 second ago" do
      
      before(:each) do
        @object.something_at = 1.second.ago
      end

      context "when urged to do a dry run in the correct context" do

        before(:each) do
          @object.urge( :something, :dry_run => true )
        end

        it "should not produce any actions" do
          @object.actions.should be_empty
        end

        it "should not be rescheduled" do
          @object.something_at.should be_nil
        end

      end

      context "when urged in the correct context" do

        before(:each) do
          @object.urge( :something )
        end

        it "should produce one action" do
          @object.actions.should have(1).item
          @object.actions.first.should == :foo
        end

        it "should not be rescheduled" do
          @object.something_at.should be_nil
        end

      end
      
      context "when urged in a non existent context" do
        
        it "should raise an error" do
          expect {
            @object.urge( :doesnt_exist )
          }.to raise_error( RuntimeError )
        end
        
      end
      
    end

  end
    
end