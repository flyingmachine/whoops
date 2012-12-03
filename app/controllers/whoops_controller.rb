class WhoopsController < ApplicationController
  layout 'whoops'

  private
  helper_method :authorized_service_lookup
  
  # overwrite this to implement rules for hiding services
  def authorized_service_lookup
    @authorized_service_lookup ||= Whoops::AuthorizedServiceLookup.new(nil)
  end

  def new_whoops_filter
    filter = Whoops::Filter.new
    filter.authorized_service_lookup = authorized_service_lookup
    filter
  end
end
