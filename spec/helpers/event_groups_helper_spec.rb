require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the EventGroupsHelper. For example:
#
# describe EventGroupsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe EventGroupsHelper do
  describe "#filter_groups" do
    it "should group services by root service and sort within groups" do
      Whoops::EventGroup.stub(:services => %w{potter.web potter.resque georgia.web georgia.backend})
      helper.filter_options.should == {"service" => [['all'], %w{georgia.backend georgia.web}, %w{potter.resque potter.web}]}
    end
  end
end
