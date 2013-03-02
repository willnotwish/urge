require 'spec_helper'

Logging.logger['simple'].tap {|logger| 
  logger.add_appenders 'colourful_stdout'
  logger.level = :info
}


# 
# 
# 
class Simple
  
  include Urge::Scheduled
  
  attr_accessor :scheduled_for
  attr_reader :actions, :logger
  
  def initialize( attrs = {} )
    self.scheduled_for = attrs[:scheduled_for]

    @logger = Logging.logger['simple']
    @actions = []
  end

  urge_schedule( :something, :scheduled_for => :scheduled_for, :action => :do_something )
  
  def do_something( options )
    @actions << :foo
    nil
  end
  
end

describe Urge::Scheduled do
  
  context "when applied to a simple, in memory object" do
    
    before(:each) do
      @object = Simple.new
    end
    
    it "should exist with no actions" do
      @object.should_not be_nil
      @object.actions.should be_empty
    end
    
    context "that is not scheduled" do
      
      context "when run in the correct context" do

        before(:each) do
          @object.run( :something )
        end

        it "should do nothing" do
          @object.actions.should be_empty
        end

      end
      
    end
    
    context "that has been scheduled to run 1 second ago" do
      
      before(:each) do
        @object.scheduled_for = 1.second.ago
      end

      context "when run in the correct context" do

        before(:each) do
          @object.run( :something )
        end

        it "should produce one action" do
          @object.actions.should have(1).item
          @object.actions.first.should == :foo
        end

        it "should not be rescheduled" do
          @object.scheduled_for.should be_nil
        end

      end
      
      context "when run in a non existent context" do
        
        it "should raise an error" do
          expect {
            @object.run( :doesnt_exist )
          }.to raise_error( RuntimeError )
        end
        
      end
      
    end

  end
    
end