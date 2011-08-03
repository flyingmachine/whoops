require 'spec_helper'

describe Whoops::EventGroup do
  let(:event_params){Whoops::Spec::ATTRIBUTES[:event_params]}
  let(:event_group_attributes) do
    {
      :identifier => "1",
      :event_type => "test",
      :service    => "test",
      :message    => "test"
    }
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
    it "sets notify_on_next_occurrence to true by default" do
      w = Whoops::EventGroup.new
      w.notify_on_next_occurrence.should be_true
    end
    
    it "only sends a notification when notify_on_next_occurrence is true and recording_event is true" do
      mailer = double
      Whoops::NotificationMailer.should_receive(:event_notification).and_return(mailer)
      mailer.should_receive(:deliver)
      Whoops::Event.record(event_params)
    end
    
    it "sets notify_on_next_occurrence to false after sending a notification" do
      event = Whoops::Event.record(event_params)
      event.event_group.notify_on_next_occurrence.should be_false
    end
    
    it "only sends notifications when recording_event is true" do
      Whoops::NotificationMailer.should_not_receive(:event_notification)
      Whoops::EventGroup.create(event_group_attributes)
    end
  end
  
  describe "archival" do
    it "sets notify_on_next_occurrence to false when archived" do
      eg = Whoops::EventGroup.create(event_group_attributes)
      eg.notify_on_next_occurrence.should be_true
      
      eg.archived = true
      eg.valid?
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
