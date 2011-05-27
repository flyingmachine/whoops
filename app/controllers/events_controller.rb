class EventsController < ApplicationController
  def index
    @event_group = Whoops::EventGroup.find(params[:whoops_event_group_id])
    @events = @event_group.events.paginate(
      :sort => [[:event_time, :desc]],
      :page => params[:page],
      :per_page => 20
    )
  end
  
  def show
    @event = Whoops::Event.find(params[:id])
    respond_to do |format|
      format.js { render :partial => 'details', :object => @event, :as => :event}
    end
  end
  
  # TODO break this out into a more metal-y controller
  def create
    Whoops::Event.record(params[:event])
    render :status => 200, :nothing => true
  end
end
