require 'spec_helper'

describe Whoops::Filter do
  let(:filter) { Whoops::Filter.new(:service => ["app.web"]) }
  let(:lookup) {
    lookup = Whoops::AuthorizedServiceLookup.new(double)
  }
  
  describe "#to_query_document" do
    it "should not include _id" do
      keys = Whoops::Filter.new.to_query_document.keys
      keys.should_not include(:_id)
      keys.should_not include("_id")
    end
  end

  describe "#matches_event_group?" do
    let(:event_group) { Whoops::EventGroup.new(:service => "app.web", :event_type => "info") }
    it "should match an event group when the filters match the event group fields" do
      filter.matches_event_group?(event_group).should be_true
    end

    it "should match .* filters" do
      filter.service = ["app.*"]
      filter.matches_event_group?(event_group).should be_true
    end

    it "should not match an event group when the filters are not equal to the event group fields" do
      filter.service = ["app.queue"]
      filter.matches_event_group?(event_group).should be_false
    end

    context "with authorized service lookup" do
      it "should not match when the authorized service lookup doesn't allow it" do
        filter.service = ["app.*"]
        lookup.stub(:authorized_services).and_return(["app2.web"])
        filter.authorized_service_lookup = lookup
        filter.matches_event_group?(event_group).should be_false
      end

      it "should match when the authorized services allows it" do
        filter.service = ["app.*"]
        lookup.stub(:authorized_services).and_return(["app.*"])
        filter.authorized_service_lookup = lookup
        filter.matches_event_group?(event_group).should be_true
      end
    end
  end

  describe "#service" do
    it "should return all services if there is no authorized service lookup" do
      filter.service.should == ["app.web"]
    end
    
    it "should return all services if there is an authorized service lookup with no authorized services" do
      filter.authorized_service_lookup = lookup
      filter.service.should == ["app.web"]
    end

    describe "#authorized_services" do
      it "should return a list of authorized services if there is an authorized_service_lookup and the service attribute is blank" do
        filter.service = []
        lookup.stub(:authorized_services).and_return(["app2.web"])
        filter.authorized_service_lookup = lookup
        filter.service.should == ["app2.web"]
      end

      it "should return only authorized services if there is an authorized service lookup and the service attribute is not blank" do
        filter.service = ["app.web", "app2.web"]
        lookup.stub(:authorized_services).and_return(["app2.*"])
        filter.authorized_service_lookup = lookup          
        filter.service.should == ["app2.web"]
      end

      it "should return all authorized services if every provided service gets filtered out" do
        filter.service = ["app.web"]
        lookup.stub(:authorized_services).and_return(["app2.*"])
        filter.authorized_service_lookup = lookup          
        filter.service.should == ["app2.*"]
      end

      it "should return authorized services when the lookup has multiple authorized services" do
        filter.service = ["app.web"]
        lookup.stub(:authorized_services).and_return(["app2.*", "app.*"])
        filter.authorized_service_lookup = lookup          
        filter.service.should == ["app.web"]
      end
    end
  end
end
