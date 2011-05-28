class EventGroupsController < ApplicationController
  layout 'whoops'
  before_filter :update_event_group_filter
  helper_method :event_group_filter
  
  def index
    @event_groups = Whoops::EventGroup.where(event_group_filter.to_query_document).desc(:last_recorded_at).paginate(
      :page => params[:page],
      :per_page => 20
    )
    
    respond_to do |format|
      format.html
      format.js { render :partial => 'list' }
    end
  end
  
  def show
    @event_group = Whoops::EventGroup.find(params[:id])
  end
  
  def update_event_group_filter
    self.event_group_filter = params[:whoops_filter] if params[:whoops_filter]
  end
  
  def event_group_filter
    session[:event_group_filter] ||= Whoops::Filter.new
  end
  
  def event_group_filter=(filter)
    session[:event_group_filter] = Whoops::Filter.new(filter)
  end
  
end