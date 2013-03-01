require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

load_schema

class SimpleGuest < ActiveRecord::Base

  include Nag::Scheduled

  nag_schedule( :default, :scheduled_for => :scheduled_for, :action => :take_action )

private

  def take_action
    logger.debug "In take_action. About to return empty set"
    nil
  end

end

FactoryGirl.define do

  factory :simple_guest do
    sequence :joined_at do |n|
      n.weeks.ago
    end

    first_name "Freddy"
    sequence :last_name do |n|
      "Starr#{n}"
    end
    
    sequence :email do |n|
      "fs#{n}@example.com"
    end
    
  end

end

describe 'Simplest active record model' do
  
  before(:each) do
    @guest = FactoryGirl.create :simple_guest, :scheduled_for => 1.day.ago
  end
  
  it "can be created" do
    @guest.should_not be_nil
  end
  
  it "can be scheduled" do
    @guest.scheduled_for.should_not be_nil
  end
  
  it "should be ready to run" do
    @guest.should be_ready_to_run( :default )
  end
  
  it "should have a nil attribute name if the attribute doesn't exist" do
    SimpleGuest.attr_name( :non_existent ).should be_nil
  end
  
  context "when run" do
    before(:each) do
      @guest.run :default
    end
    
    it "should not be rescheduled" do
      @guest.scheduled_for.should be_nil
    end
  end
  
end

describe "AR finders" do
  
  before(:each) do
    
    SimpleGuest.delete_all
    
    @count = 10
    @count.times do |index|
      FactoryGirl.create :simple_guest, :scheduled_for => 1.day.ago
    end
  end
  
  it "should return the correct number guests ready to run" do
    SimpleGuest.ready_to_run( :default ).should have(@count).items
  end
  
end

