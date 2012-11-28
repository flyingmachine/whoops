require 'spec_helper'

describe Whoops::Filter do
  describe "#to_query_document" do
    it "should not include _id" do
      keys = Whoops::Filter.new.to_query_document.keys
      keys.should_not include(:_id)
      keys.should_not include("_id")
    end
  end

  describe "#matches_event_group?" do
    let(:filter) { Whoops::Filter.new(:service => ["app.web"]) }
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
  end
end
