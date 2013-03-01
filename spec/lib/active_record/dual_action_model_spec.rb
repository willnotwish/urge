require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

load_schema

class DualActionGuest < ActiveRecord::Base

  include Urge::Scheduled

  urge_schedule( :status_check,    :scheduled_for => :status_check_at, :action => :check_status )
  urge_schedule( :insurance_check, :scheduled_for => :insurance_check_at, :action => :check_insurance )
  
  def status_checked?
    @status_checked
  end
  
  def insurance_checked?
    @insurance_checked
  end

private

  def check_status
    logger.debug "In check_status"
    @status_checked = true
    nil
  end
  
  def check_insurance
    logger.debug "In check_insurance"
    @insurance_checked = true
    nil
  end

end


FactoryGirl.define do

  factory :dual_action_guest do
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

describe 'AR model with more than one schedule' do
  
  context "when created" do

    before(:each) do
      @guest = FactoryGirl.create :dual_action_guest, :status_check_at => 1.hour.ago, :insurance_check_at => 1.day.ago
      @guest.should_not be_nil
    end
    
    context "both checks" do

      before(:each) do
        @checks = [:status_check, :insurance_check]
      end

      it "both checks should be ready to run" do
        @checks.each { |c| @guest.should be_ready_to_run( c ) }
      end

      context "when run" do
        before(:each) do
          @checks.each { |c| @guest.run( c )}
        end
        
        it "should result in the guest having his status and his insurance checked" do
          @guest.should be_status_checked
          @guest.should be_insurance_checked
        end
        
      end

    end

  end
  
end


describe "AR finders" do
  
  before(:each) do
    DualActionGuest.delete_all
    @count = 10
    @count.times do |index|
      FactoryGirl.create :dual_action_guest, :status_check_at => 1.hour.ago, :insurance_check_at => 1.day.ago
    end
  end
  
  it "should return the correct number guests ready to run" do
    expect {
      DualActionGuest.ready_to_run( :default )
    }.to raise_error( RuntimeError )
    
    DualActionGuest.ready_to_run( :status_check ).should have(@count).items
    DualActionGuest.ready_to_run( :insurance_check ).should have(@count).items
  end
  
end
