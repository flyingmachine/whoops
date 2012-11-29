require 'spec_helper'

describe Whoops::NotificationMailer do

  describe '.event_notification' do
    let(:event_params){Whoops::Spec::ATTRIBUTES[:event_params]}
    let(:event_group){ record_new_event }
    let(:event){ event_group.events.first }
    
    def record_new_event
      Whoops::NewEvent.new(event_params).record!
    end

    let(:addresses  ) { ['test@example.com', 'another@test.com'] }
    subject { Whoops::NotificationMailer.event_notification(event_group, addresses) }

    its(:to     ) { should == ['test@example.com', 'another@test.com'] }
    its(:from   ) { should == ['dummy@test.com'] }
    its(:subject) { should == "Whoops Notification | test.service: production: ArgumentError" }

    context "body" do
      subject { Whoops::NotificationMailer.event_notification(event_group, addresses).body.to_s }
      it { should == <<-BODY
http://test.com/event_groups/#{event_group.id}/events

test.service: production: ArgumentError
BODY
    }
    end
  end

end
