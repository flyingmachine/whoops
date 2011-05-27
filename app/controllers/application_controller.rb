class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :event_group_filter
  
  def event_group_filter
    session[:event_group_filter] ||= Whoops::Filter.new
  end
  
  def event_group_filter=(filter)
    session[:event_group_filter] = Whoops::Filter.new(filter)
  end
end
