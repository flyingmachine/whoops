require 'spec_helper'

describe Whoops::EventGroup do
  let(:event_params){Whoops::Spec::ATTRIBUTES[:event_params]}
  let(:event_group_attributes) do
    Fabricate.attributes_for("Whoops::EventGroup", :service => "app.background.data.processor")
  end
  
  describe ".services" do
    it "should not return the common namespace" do
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
    
    it "should send a notification when archived is true and whoops_sender is set" do
      eg = create_event_group
      eg.archived = true
      eg.save
      Whoops::NotificationRule::Matcher.any_instance.stub(:matches).and_return([Whoops::NotificationRule.new(:email => "test@test.com")])
      lambda { 
        create_event_group
      }.should change(ActionMailer::Base.deliveries, :size)
    end

    it "should send a notification when the record is new and whoops_sender is set" do
      Whoops::NotificationRule::Matcher.any_instance.stub(:matches).and_return([Whoops::NotificationRule.new(:email => "test@test.com")])
      lambda { 
        create_event_group
      }.should change(ActionMailer::Base.deliveries, :size)
    end
    
    it "does not send an email if archived is false and the event group is not a new record" do
      eg = create_event_group
      Whoops::NotificationRule::Matcher.any_instance.stub(:matches).and_return([Whoops::NotificationRule.new(:email => "test@test.com")])
      lambda { 
        create_event_group
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
      eg.reload.archived.should be_true
      
      Whoops::Event.record(event_params)
      eg.reload.archived.should be_false
    end
  end
end
