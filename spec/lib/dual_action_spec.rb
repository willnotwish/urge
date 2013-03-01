require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# 
# 
# 
class TwoTask
  
  include Urge::Scheduled
  
  attr_accessor :scheduled_for_one, :scheduled_for_two
  
  attr_reader :logger
  
  def initialize( attrs, options )
    @scheduled_for_one = attrs[:scheduled_for_one]
    @scheduled_for_two = attrs[:scheduled_for_two]

    @logger = options[:logger] || Logging.logger['scheduled_test']

    @actions = options[:actions]
  end

  urge_schedule( :one, :scheduled_for => :scheduled_for_one, :action => :take_one )
  urge_schedule( :two, :scheduled_for => :scheduled_for_two, :action => :take_two )
  
  def take_one
    @actions << :action_one
    1.hour
  end
  
  def take_two
    @actions << :action_two
    2.hours
  end
  
end

describe Urge::Scheduled do
  
  context "when applied to an in memory object requiring two separate actions, that object" do
    
    before(:each) do
      @actions = []
      @attrs = {
        :scheduled_for_one => 1.second.ago,
        :scheduled_for_two => 2.seconds.ago
      }
      @object = TwoTask.new @attrs, :actions => @actions
    end
    
    it "should exist with no actions" do
      @object.should_not be_nil
      @actions.should be_empty
    end
    
    context "when run in the context of task 1" do
      
      before(:each) do
        @object.run( :one )
      end
      
      it "should produce one action" do
        @actions.should have(1).item
        @actions.first.should == :action_one
      end
      
      it "should be rescheduled for one hour's time" do
        @object.scheduled_for_one.to_i.should eq(( Time.now + 1.hour).to_i )
      end
      
    end

    context "when run in the context of task 2" do
      
      before(:each) do
        @object.run( :two )
      end
      
      it "should produce another action" do
        @actions.should have(1).item
        @actions.first.should == :action_two
      end

      it "should be rescheduled for two hours' time" do
        @object.scheduled_for_two.to_i.should eq( (Time.now + 2.hours).to_i )
      end
      
    end
    
    context "when run in the context of both tasks" do

      before(:each) do
        @object.run( :one )
        @object.run( :two )
      end

      it "should produce two actions" do
        @actions.should have(2).items
        @actions.should include( :action_one)
        @actions.should include( :action_two)
      end

    end
    
  end
    
end