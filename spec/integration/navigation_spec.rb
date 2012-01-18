require 'spec_helper'

describe "Navigation" do
  include Capybara
  
  it "should be a valid app" do
    ::Rails.application.should be_a(Dummy::Application)
  end
  
  it "should display filters" do
    visit whoops_event_groups_path
    page.should have_content("Filters")
  end


  it "should display event groups" do
    e = Whoops::EventGroup.handle_new_event(Whoops::Spec::ATTRIBUTES[:event_params])
    e.should be_valid
    visit whoops_event_groups_path
    page.should have_content("ArgumentError")
  end
end
