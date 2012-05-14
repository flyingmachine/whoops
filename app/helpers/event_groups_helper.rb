module EventGroupsHelper
  def event_group_scoped_link(event_group, scope)
    new_filter  = {:whoops_filter => event_group_filter.to_query_document.merge(scope => event_group.send(scope))}
    link_to(event_group.send(scope), whoops_event_groups_path(new_filter))
  end
  
  # meant for consumption by options_from_collection_for_select
  def filter_options
    all_event_groups = Whoops::EventGroup.all
    return @filter_options if @filter_options

    @filter_options = Hash.new{|h, k| h[k] = []}
    
    @filter_options["service"] = Whoops::EventGroup.services.to_a
    @filter_options["environment"] = Whoops::EventGroup.all.distinct("environment")
    @filter_options["event_type"] = Whoops::EventGroup.all.distinct("event_type")

    # add the field name as an empty option
    @filter_options.keys.each do |field_name|
      @filter_options[field_name].compact!
      @filter_options[field_name].sort!{|a, b| a.first <=> b.first}.uniq! if @filter_options[field_name]
    end

    @filter_options
  end

  def filter_checked?(field_name, option)
    filtered_field = session[:event_group_filter].send(field_name)
    filtered_field && filtered_field.include?(option)
  end
end
