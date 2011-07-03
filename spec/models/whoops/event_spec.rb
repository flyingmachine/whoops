require 'spec_helper'

describe Whoops::Event do
  let(:event_params){Whoops::Spec::ATTRIBUTES[:event_params]}
  
  describe ".record" do
    it "should create an EventGroup if one does not already exist" do
      Whoops::Event.record(event_params)
      event_group = Whoops::EventGroup.first
      event_group.event_type.should == event_params[:event_type]
      event_group.service.should == event_params[:service]
      event_group.environment.should == event_params[:environment]
      event_group.identifier.should == event_params[:event_group_identifier]
      event_group.message.should == event_params[:message]
    end
    
    it "should create an event with event_group_id set to event group id and with details and event time" do
      event = Whoops::Event.record(event_params)      
      event_group = Whoops::EventGroup.first

      event.event_group_id.should == event_group.id
      event.details.should == {"line"=>"32", "file"=>"fail.rb"}
      event.message.should == event_params[:message]
      event.event_time.to_s(:whoops_default).should == DateTime.parse(event_params[:event_time]).to_s(:whoops_default)
      event.event_time.should == event_group.last_recorded_at
    end
    
    it "should add an event to an existing event group if group identifier matches" do
      2.times{ Whoops::Event.record(event_params) }
      event_group = Whoops::EventGroup.first
      Whoops::Event.where(:event_group_id => event_group.id.to_s).size.should == 2
    end
  end
  
  describe ".search" do
    let(:query) { "details.file /fail/" }
    it "should return matching records" do
      event = Whoops::Event.record(event_params)
      Whoops::Event.search(query).should include(event)
    end
    
    it "should not return non-matching records" do
      event_params[:details][:file] = 'success.rb'
      event = Whoops::Event.record(event_params)
      Whoops::Event.search(query).should_not include(event)
    end
  end
end