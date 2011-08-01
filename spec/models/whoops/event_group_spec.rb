require 'spec_helper'

describe Whoops::EventGroup do
  describe ".services" do
    it "should return the common namespace, even if not actually present in records" do
      Fabricate("Whoops::EventGroup", :service => "app.background.data.processor")
      Fabricate("Whoops::EventGroup", :service => "app.background.data.loader")
      
      Whoops::EventGroup.services.should include("app.background.data")
      Whoops::EventGroup.services.should_not include("app.background")
      Whoops::EventGroup.services.should_not include("app")
    end
  end
  
  describe "notification" do
    it "sets notify_on_next_occurrence to true by default" do
      w = Whoops::EventGroup.new      
      w.notify_on_next_occurrence.should be_true
    end
    
    it "sends a notification when notify_on_next_occurrence is true" do
      
    end
    
    it "sets notify_on_next_occurrence to false after sending a notification"
  end
end
