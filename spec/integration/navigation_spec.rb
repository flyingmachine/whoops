require 'spec_helper'

describe "Navigation" do
  include Capybara
  
  it "should be a valid app" do
    ::Rails.application.should be_a(Dummy::Application)
  end
  
  it "should display event groups" do
    visit whoops_event_groups_path
    page.should have_content("Filters")
  end
end
