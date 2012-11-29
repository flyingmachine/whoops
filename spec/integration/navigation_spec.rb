require 'spec_helper'

describe "Navigation" do
  include Capybara::DSL
  let(:event_params){Whoops::Spec::ATTRIBUTES[:event_params]}
  let(:event_group){ record_new_event }
  let(:event){ event_group.events.first }

  def record_new_event
    Whoops::NewEvent.new(event_params).record!
  end

  it "should be a valid app" do
    ::Rails.application.should be_a(Dummy::Application)
  end

  it "should display filters" do
    visit whoops_event_groups_path
    page.should have_content("Filters")
  end


  it "should display event groups" do
    record_new_event
    visit whoops_event_groups_path
    page.should have_content("ArgumentError")
  end

  it "should display event group" do
    visit whoops_event_group_events_path(event_group)
    page.should have_content("ArgumentError")
  end

  it "should display event group with query" do
    visit whoops_event_group_events_path(event_group, :query => "message#in ['ArgumentError']")
    page.should have_content("ArgumentError")
    #TODO use i18n
    page.should_not have_content("Your search returned no results")
  end

  it "should not display event groups which don't match query" do
    visit whoops_event_group_events_path(event_group, :query => "message#in ['Blorazrea']")
    page.should have_content("Your search returned no results")
  end
end
