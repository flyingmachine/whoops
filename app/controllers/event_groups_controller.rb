class EventGroupsController < ApplicationController
  before_filter :update_event_group_filter
  def index
    @event_groups = Whoops::EventGroup.paginate(
      :conditions => event_group_filter.to_query_document,
      :sort => [[:last_recorded_at, :desc]],
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
end
