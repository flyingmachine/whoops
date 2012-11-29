require 'spec_helper'

describe Whoops::Event do
  let(:event_params){Whoops::Spec::ATTRIBUTES[:event_params]}
  let(:event_group){ record_new_event }
  let(:event){ event_group.events.first }

  def record_new_event
    Whoops::NewEvent.new(event_params).record!
  end

  describe ".search" do
    let(:query) { "details.file !r/fail/" }
    it "should return matching records" do
      event
      Whoops::Event.search(query).should include(event)
    end

    it "should not return non-matching records" do
      p = event_params.clone
      p[:details] = p[:details].merge(:file => 'success.rb')
      event_group = Whoops::NewEvent.new(p).record!
      Whoops::Event.search(query).should_not include(event_group.events.first)
    end
  end

  describe "#add_details_to_keywords" do
    event = Whoops::Event.create(:message => "test", :details => {:one => "two", :three => {:four => "five"}})
    event.keywords.should == "test two five"
  end

  describe "#sanitize_details" do
    it "should replace periods with underscores in top-level details keys" do
      event = Whoops::Event.create(:message => "test", :details => {"has.period" => "yes"})
      event.details.should == {"has_period" => "yes"}
    end

    it "should replace periods with underscores in top-level details keys" do
      event = Whoops::Event.create(
        :message => "test",
        :details => {
          "outer" => {"inner.period" => true}
        }
      )
      event.details.should == {"outer" => {"inner.period" => true}.to_s }
    end
  end
end
