# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "rspec/rails"
require "fabrication"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Configure capybara for integration testing
require "capybara/rails"
Capybara.default_driver   = :rack_test
Capybara.default_selector = :css

# Load support files
Dir[
  "#{File.dirname(__FILE__)}/support/**/*.rb",
  "#{File.dirname(__FILE__)}/fabricators/**/*.rb"
].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  # methods or matchers
  require 'rspec/expectations'
  config.include RSpec::Matchers
  
  config.before(:each) do
    Mongoid::Config.master.collections.select{|c| c.name !~ /^system\./}.each(&:remove)
  end

  config.after :suite do
    Mongoid::Config.master.collections.select{|c| c.name !~ /^system\./}.each(&:remove)
  end
end

module Whoops
  module Spec
    ATTRIBUTES = {
      :event_params => {
        :event_type => "error",
        :service => "test.service",
        :environment => "production",
        :message => "ArgumentError",
        :event_group_identifier => "3r42",
        :event_time => Time.now.to_s,
        :details => {
          :line => "32",
          :file => "fail.rb"
        }
      }
    }
  end
end