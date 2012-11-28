module EventGroupsHelper
  def event_group_scoped_link(event_group, scope)
    new_filter  = {:whoops_filter => event_group_filter.to_query_document.merge(scope => event_group.send(scope))}
    link_to(event_group.send(scope), whoops_event_groups_path(new_filter))
  end

  def filter_field_allowed_values
    return @filter_field_allowed_values if @filter_field_allowed_values
    @filter_field_allowed_values = Hash.new{|h, k| h[k] = [["all"]]}

    # group services by root, eg "sv1.web" and "sv1.resque" are in the
    # same sub array
    previous_service_root = ""
    Whoops::EventGroup.services.to_a.sort.each { |service|
      service_root = (/(.*?)\./ =~ service && $~[1]) || service
      if service_root == previous_service_root
        @filter_field_allowed_values["service"].last << service
      else
        @filter_field_allowed_values["service"] << ["#{service_root}.*", service]
        previous_service_root = service_root
      end
    }

    @filter_field_allowed_values["environment"] << Whoops::EventGroup.all.distinct("environment")
    @filter_field_allowed_values["event_type"] << Whoops::EventGroup.all.distinct("event_type")
    @filter_field_allowed_values
  end

  def allowed_value_checked?(field_name, allowed_value, filter)
    filtered_field = filter.send(field_name)
    (allowed_value == "all" && filtered_field_allows_all?(filtered_field)) ||
      filtered_field.try(:include?, allowed_value)
  end

  def filtered_field_allows_all?(filtered_field)
    filtered_field.blank?
  end
end
