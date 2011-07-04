require 'spec_helper'

describe Whoops::NotificationRule do
  let(:rule) { 
    Whoops::NotificationRule.create(
      :email => "Daniel@Higginbotham.com",
      :matchers => "test.service "
    )
  }
  
  it "downcases the email on save" do
    rule.email.should == "daniel@higginbotham.com"
  end
  
  it "converts the matchers to an array and strips each matcher of whitespace" do
    rule.matchers.should == ["test.service"]
  end
  
  describe Whoops::NotificationRule::Matcher do
    let(:event_params){ Whoops::Spec::ATTRIBUTES[:event_params] }
    let(:event){ Whoops::Event.record(event_params) }
    let(:event_group){ event.event_group }
    let(:matcher){ Whoops::NotificationRule::Matcher.new(event_group) }
    
    it "requires an event group object for initializtion" do
      lambda{ Whoops::NotificationRule::Matcher.new }.should raise_error
    end
    
    describe "#matches" do
      it "is empty when there are no matches" do
        rule.matchers = "gobbledygook"
        rule.save
        matcher.matches.should be_empty
      end
      
      it "returns all NotificationRule object where the matchers contain a string which match the event group's service" do
        matcher.matches.should == [rule]
      end
    end
    
    describe "#matching_emails" do
      it "returns a de-duped array of all emails that correspond with matching rules" do
        rule
        Whoops::NotificationRule.create(
          :email => "daniel@higginbotham.com",
          :matchers => "test.service"
        )
        
        Whoops::NotificationRule.all.size.should == 2
        matcher.matching_emails.should == ["daniel@higginbotham.com"]
      end
      
      it "returns an empty array when there are no matches" do
        rule.matchers = "gobbledygook"
        rule.save
        matcher.matching_emails.should == []
      end
    end
  end
end
