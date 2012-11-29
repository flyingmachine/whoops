require 'spec_helper'

describe Whoops::NewEvent do
  let(:event_params){Whoops::Spec::ATTRIBUTES[:event_params]}
  let(:event_group){ record_new_event }
  let(:event){ event_group.events.first }

  def record_new_event
    Whoops::NewEvent.new(event_params).record!
  end
  
  describe "#record!" do
    it "should create an EventGroup if one does not already exist" do
      event_group.event_type.should == event_params[:event_type]
      event_group.service.should == event_params[:service]
      event_group.environment.should == event_params[:environment]
      event_group.event_group_identifier.should == event_params[:event_group_identifier]
      event_group.message.should == event_params[:message]
    end

    it "should create an event with event_group_id set to event group id and with details and event time" do
      event.event_group_id.should == event_group.id
      event.details.should == {"line"=>"32", "file"=>"fail.rb"}
      event.message.should == event_params[:message]
    end

    it "should update the event group's 'last_recorded_at'" do
      event_group.last_recorded_at = 5.minutes.ago
      event_group.save
      old_time = event_group.last_recorded_at

      event_group = record_new_event
      event_group.last_recorded_at.should_not == old_time
    end

    it "should add an event to an existing event group if group identifier matches" do
      2.times{ record_new_event }
      event_group = Whoops::EventGroup.first
      Whoops::Event.where(:event_group_id => event_group.id.to_s).size.should == 2
    end
  end

  describe "notification" do
    before(:each) do
      Whoops::NotificationSubscription::Matcher.any_instance.stub(:matching_emails).and_return([Whoops::NotificationSubscription.new(:email => "test@test.com")])
    end
    
    it "should send a notification when archived is true and whoops_sender is set" do
      event_group.archived = true
      event_group.save
      
      lambda { 
        record_new_event
      }.should change(ActionMailer::Base.deliveries, :size)
    end

    it "should send a notification when the record is new and whoops_sender is set" do
      lambda { 
        record_new_event
      }.should change(ActionMailer::Base.deliveries, :size)
    end
    
    it "does not send an email if archived is false and the event group is not a new record" do
      eg = record_new_event
      lambda { 
        record_new_event
      }.should_not change(ActionMailer::Base.deliveries, :size)
    end
    
    it "does not send an email if there are no notification matcher matches matches" do
      Whoops::NotificationSubscription::Matcher.any_instance.stub(:matching_emails).and_return([])
      lambda { 
        Fabricate("Whoops::EventGroup", :service => "app.background.data.processor")
      }.should_not change(ActionMailer::Base.deliveries, :size)
    end
  end

  describe "archival" do
    it "sets an event group's archived field to false when a new event is recorded" do
      event_group = record_new_event
      event = event_group.events.first
      
      event_group.archived = true
      event_group.save
      event_group.reload.archived.should be_true
      
      record_new_event
      event_group.reload.archived.should be_false
    end
  end
end
