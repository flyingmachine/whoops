require 'spec_helper'

describe Whoops::NotificationSubscription do
  let(:subscription) { 
    Whoops::NotificationSubscription.create(
      :email => "Daniel@Higginbotham.com",
      :filter => Whoops::Filter.new(:service => ["test.*"])
    )
  }

  let(:event_params){Whoops::Spec::ATTRIBUTES[:event_params]}
  let(:event_group){ record_new_event }
  let(:event){ event_group.events.first }

  def record_new_event
    Whoops::NewEvent.new(event_params).record!
  end
  
  it "downcases the email on save" do
    subscription.email.should == "daniel@higginbotham.com"
  end

  describe Whoops::NotificationSubscription::Matcher do
    let(:matcher){ Whoops::NotificationSubscription::Matcher.new(event_group) }
    
    it "should return the email addresses of subscriptions whose filters match an event group" do
      subscription.filter.save

      nomatch = Whoops::NotificationSubscription.create(
        :email => "does_not@match.com",
        :filter => Whoops::Filter.new(:service => ["not_test.*"])
        )
      nomatch.filter.save
      
      matcher.matching_emails.should == ["daniel@higginbotham.com"]
    end
  end
end
