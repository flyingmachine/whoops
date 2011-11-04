require 'spec_helper'

describe Whoops::EventGroup do
  let(:event_params){Whoops::Spec::ATTRIBUTES[:event_params]}
  let(:event_group_attributes) do
    Fabricate.attributes_for("Whoops::EventGroup", :service => "app.background.data.processor")
  end
  
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
    def create_event_group
      Whoops::EventGroup.handle_new_event(event_group_attributes)
    end
    
    it "sets notify_on_next_occurrence to true by default" do
      w = Whoops::EventGroup.new
      w.notify_on_next_occurrence.should be_true
    end
    
    it "sends a notification when notify_on_next_occurrence is true and there are matcher matches" do
      Whoops::NotificationRule::Matcher.any_instance.stub(:matches).and_return(["test@test.com"])
      lambda { 
        create_event_group
      }.should change(ActionMailer::Base.deliveries, :size)
    end
    
    it "sets notify_on_next_occurrence to false after sending a notification" do
      Whoops::NotificationRule::Matcher.any_instance.stub(:matches).and_return(["test@test.com"])
      w = create_event_group
      w.notify_on_next_occurrence.should be_false
    end
    
    it "does not send an email if notify_on_next_occurrence is false" do
      Whoops::NotificationRule::Matcher.any_instance.stub(:matches).and_return(["test@test.com"])
      lambda { 
        Fabricate("Whoops::EventGroup", :service => "app.background.data.processor", :notify_on_next_occurrence => false)
      }.should_not change(ActionMailer::Base.deliveries, :size)
    end
    
    it "does not send an email if there are no notification matcher matches matches" do
      Whoops::NotificationRule::Matcher.any_instance.stub(:matches).and_return([])
      lambda { 
        Fabricate("Whoops::EventGroup", :service => "app.background.data.processor")
      }.should_not change(ActionMailer::Base.deliveries, :size)
    end
  end
  
  describe "archival" do
    it "sets notify_on_next_occurrence to false when archived" do
      eg = Whoops::EventGroup.create(event_group_attributes)
      eg.notify_on_next_occurrence.should be_true
      eg.archived = true
      eg.handle_archival
      eg.notify_on_next_occurrence.should be_false
    end
    
    it "sets archived to false when a new event is recorded" do
      event = Whoops::Event.record(event_params)
      eg = event.event_group
      
      eg.archived = true
      eg.save
      
      Whoops::Event.record(event_params)
      eg.reload.archived.should be_false
    end
  end
end
