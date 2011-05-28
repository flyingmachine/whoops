module EventsHelper
  def format_detail(detail)
    case detail
    when String, Numeric: detail
    when Array: detail.join("<br />")
    when Hash: detail_table(detail)
    else
      detail.to_s
    end.html_safe
  end
  
  def detail_table(detail)
    render :partial => 'events/detail', :object => detail
  end
  
  def breadcrumbs(*groups)
    breadcrumbs = ""
    groups.each do |group|
      breadcrumbs << "<div class='breadcrumb_divider'></div>"
      if groups.last == group
        breadcrumbs << "<a class='current'>#{group.first}</a>"
      else
        breadcrumbs << link_to(group.first, group.last)
      end
    end
    breadcrumbs.html_safe
  end
end
