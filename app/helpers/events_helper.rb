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
end
