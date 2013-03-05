require 'spec_helper'

# Logging.logger['urge'].tap {|logger| 
#   logger.add_appenders 'colourful_stdout'
#   logger.level = :debug
# }

class Simple

  attr_accessor :something_at
  attr_reader :actions
  
  def initialize( attrs = {} )
    self.something_at = attrs[:something_at]
    @actions = []
  end

  def do_something( options )
    @actions << :foo
    nil
  end
  
  # By including the Urge module, we drag in all the class methods from that module
  include Urge
  urge_schedule :something, :action => 'do_something'

end

Logging.logger[Simple].tap {|logger| 
  logger.add_appenders 'colourful_stdout'
  logger.level = :debug
}

Simple.urge_logger = Logging.logger[Simple]


describe Urge do
  
  context "when applied to a simple, in memory object" do
    
    before(:each) do
      @object = Simple.new
    end
    
    it "should exist with no actions" do
      @object.should_not be_nil
      @object.actions.should be_empty
    end
    
    context "that has been scheduled to run 1 second ago" do
      
      before(:each) do
        @object.something_at = 1.second.ago
      end

      context "when urged to do something" do

        before(:each) do
          @object.urge( :something )
        end

        it "should produce an actions" do
          @object.actions.should_not be_empty
        end

        it "should not be rescheduled" do
          @object.something_at.should be_nil
        end

      end

    end

  end
    
end