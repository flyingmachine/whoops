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
    
    it "sends a notification when notify_on_next_occurrence is true and there are matcher matches" do
      Whoops::NotificationRule::Matcher.any_instance.stubs(:matches).returns(["test@test.com"])
      lambda { 
        Fabricate("Whoops::EventGroup", :service => "app.background.data.processor")
      }.should change(ActionMailer::Base.deliveries, :size)
    end
    
    it "sets notify_on_next_occurrence to false after sending a notification" do
      Whoops::NotificationRule::Matcher.any_instance.stubs(:matches).returns(["test@test.com"])
      w = Fabricate("Whoops::EventGroup", :service => "app.background.data.processor")
      w.notify_on_next_occurrence.should be_false
    end
    
    it "does not send an email if notify_on_next_occurrence is false" do
      Whoops::NotificationRule::Matcher.any_instance.stubs(:matches).returns(["test@test.com"])
      lambda { 
        Fabricate("Whoops::EventGroup", :service => "app.background.data.processor", :notify_on_next_occurrence => false)
      }.should_not change(ActionMailer::Base.deliveries, :size)
    end
    
    it "does not send an email if there are no notification matcher matches matches" do
      Whoops::NotificationRule::Matcher.any_instance.stubs(:matches).returns([])
      lambda { 
        Fabricate("Whoops::EventGroup", :service => "app.background.data.processor")
      }.should_not change(ActionMailer::Base.deliveries, :size)
    end
  end
end
