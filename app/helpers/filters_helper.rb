module FiltersHelper
  def summarize_filter(arr)
    arr.blank? ? "all" : arr.sort.collect{|x| "<span>#{x}</span>".html_safe }.join(" ").html_safe 
  end
end
