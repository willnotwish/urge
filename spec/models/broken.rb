require 'spec_helper'

Logging.logger['urge'].tap {|logger| 
  logger.add_appenders 'colourful_stdout'
  logger.level = :debug
}

# 
# 
# 
class Broken

  # By including the Urge module, we drag in all the class methods from that module
  include Urge
  
  attr_accessor :something_at
  attr_reader :actions, :logger
  
  def initialize( attrs = {} )
    self.something_at = attrs[:something_at]
    @actions = []
  end

  urge_schedule :something, :action => 'break_something'
  
  def break_something( options )
    raise 'broken'
    nil
  end
  
end


describe Urge do
  
  context "when applied to a broken, in memory object" do
    
    before(:each) do
      @object = Broken.new
    end
    
    context "that has been scheduled to run 1 second ago" do
      
      before(:each) do
        @object.something_at = 1.second.ago
      end

      it "should not break when urged to do something that is broken" do
        expect {@object.urge( :something )}.not_to raise_error
      end
      
      it "but should return false" do
        @object.urge( :something ).should be_false
      end
   
    end

  end
    
end