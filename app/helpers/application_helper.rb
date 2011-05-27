module ApplicationHelper
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
