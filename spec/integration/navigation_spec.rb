require 'spec_helper'

describe "Navigation" do
  include Capybara::DSL

  it "should be a valid app" do
    ::Rails.application.should be_a(Dummy::Application)
  end

  it "should display filters" do
    visit whoops_event_groups_path
    page.should have_content("Filters")
  end


  it "should display event groups" do
    Whoops::Event.record(Whoops::Spec::ATTRIBUTES[:event_params])
    visit whoops_event_groups_path
    page.should have_content("ArgumentError")
  end

  it "should display event group" do
    Whoops::Event.record(Whoops::Spec::ATTRIBUTES[:event_params])
    e = Whoops::EventGroup.first
    visit whoops_event_group_events_path(e)
    page.should have_content("ArgumentError")
  end

  it "should display event group with query" do
    Whoops::Event.record(Whoops::Spec::ATTRIBUTES[:event_params])
    e = Whoops::EventGroup.first
    visit whoops_event_group_events_path(e, :query => "message#in ['ArgumentError']")
    page.should have_content("ArgumentError")
    #TODO use i18n
    page.should_not have_content("Your search returned no results")
  end

  it "should not display event groups which don't match query" do
    Whoops::Event.record(Whoops::Spec::ATTRIBUTES[:event_params])
    e = Whoops::EventGroup.first
    visit whoops_event_group_events_path(e, :query => "message#in ['Blorazrea']")
    page.should have_content("Your search returned no results")
  end
end
