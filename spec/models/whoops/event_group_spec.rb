require 'spec_helper'

describe Whoops::EventGroup do
  let(:event_params){Whoops::Spec::ATTRIBUTES[:event_params]}
  let(:event_group_attributes) do
    Fabricate.attributes_for("Whoops::EventGroup", :service => "app.background.data.processor")
  end
  
  describe ".services" do
    it "should not return the common namespace, even if not actually present in records" do
      Fabricate("Whoops::EventGroup", :service => "app.background.data.processor")
      Fabricate("Whoops::EventGroup", :service => "app.background.data.loader")

      Whoops::EventGroup.services.should_not include("app.background.data")
      Whoops::EventGroup.services.should_not include("app.background")
      Whoops::EventGroup.services.should_not include("app")
    end
  end
  
  describe "notification" do
    def create_event_group
      Whoops::EventGroup.handle_new_event(event_group_attributes)
    end
    
    it "sends a notification when archived is true and there are matcher matches" do
      Whoops::NotificationRule::Matcher.any_instance.stub(:matches).and_return(["test@test.com"])
      lambda { 
        e = create_event_group
        e.archived = true
        e.save
      }.should change(ActionMailer::Base.deliveries, :size)
    end
    
    it "does not send an email if archived is false" do
      Whoops::NotificationRule::Matcher.any_instance.stub(:matches).and_return(["test@test.com"])
      lambda { 
        Fabricate("Whoops::EventGroup", :service => "app.background.data.processor", :archived => false)
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
