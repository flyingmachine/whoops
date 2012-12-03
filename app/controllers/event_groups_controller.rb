class EventGroupsController < WhoopsController
  before_filter :update_event_group_filter
  helper_method :event_group_filter
  
  def index
    query_document = event_group_filter.to_query_document
    query_document.merge!(:archived => false) unless params[:show_archived]
    query_document.merge!(:_id.in => Whoops::Event.where(:keywords => /#{params[:query]}/i).distinct(:event_group_id)) unless params[:query].blank?
    
    @event_groups = Whoops::EventGroup.where(query_document).desc(:last_recorded_at).page(params[:page]).per(30)
    
    respond_to do |format|
      format.html
      format.js { render :partial => 'list' }
    end
  end
  
  def show
    @event_group = Whoops::EventGroup.find(params[:id])
  end
  
  def update_event_group_filter
    self.event_group_filter = params[:whoops_filter] if params[:updating_filters]
  end
  
  def event_group_filter
    session[:event_group_filter] ||= Whoops::Filter.new
  end
  
  def event_group_filter=(filter)
    session[:event_group_filter] = Whoops::Filter.new_from_params(filter)
  end

  def update
    @event_group = Whoops::EventGroup.find(params[:id])
    @event_group.update_attributes(:archived => params[:event_group][:archived] == "true")
    redirect_to whoops_event_group_events_path(@event_group)
  end
  
end
