require 'spec_helper'

describe Whoops::EventGroup do
  let(:event_params){Whoops::Spec::ATTRIBUTES[:event_params]}
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
      Whoops::EventGroup.create(
        :identifier => "1",
        :event_type => "test",
        :service    => "test",
        :message    => "test"
      )
    end
  end
  
  describe "archival" do
    it "sets notify_on_next_occurrence to false when archived"
    
    it "sets becomes unarchived when a new event is recorded"
  end
end
