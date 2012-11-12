require 'spec_helper'

describe Whoops::NotificationMailer do

  describe '.event_notification' do
    let(:event_group_attributes) do
      Fabricate.attributes_for("Whoops::EventGroup", :service => "app.background.data.processor")
    end
    let(:event_group) { Whoops::EventGroup.handle_new_event(event_group_attributes) }
    let(:addresses  ) { ['test@example.com', 'another@test.com'] }
    subject { Whoops::NotificationMailer.event_notification(event_group, addresses) }

    its(:to     ) { should == ['test@example.com', 'another@test.com'] }
    its(:from   ) { should == ['dummy@test.com'] }
    its(:subject) { should == "Whoops Notification | app.background.data.processor: production: ArgumentError" }
    its(:body   ) { should == <<-BODY
http://test.com/event_groups/#{event_group.id}/events

app.background.data.processor: production: ArgumentError
BODY
                  }
  end

end
