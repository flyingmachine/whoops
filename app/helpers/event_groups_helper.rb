module EventGroupsHelper
  def event_group_scoped_link(event_group, scope)
    new_filter  = {:whoops_filter => event_group_filter.to_query_document.merge(scope => event_group.send(scope))}
    link_to(event_group.send(scope), whoops_event_groups_path(new_filter))
  end

  def filter_options
    return @filter_options if @filter_options
    @filter_options = Hash.new{|h, k| h[k] = [["all"]]}

    # group services by root, eg "sv1.web" and "sv1.resque" are in the
    # same sub array
    previous_service_root = ""
    Whoops::EventGroup.services.to_a.sort.each { |service|
      service_root = (/(.*?)\./ =~ service && $~[1]) || service
      if service_root == previous_service_root
        @filter_options["service"].last << service
      else
        @filter_options["service"] << [service]
        previous_service_root = service_root
      end
    }

    @filter_options["environment"] << Whoops::EventGroup.all.distinct("environment")
    @filter_options["event_type"] << Whoops::EventGroup.all.distinct("event_type")
    @filter_options
  end

  def filter_checked?(field_name, option)
    filtered_field = session[:event_group_filter].send(field_name)
    filtered_field && filtered_field.include?(option)
  end
end
