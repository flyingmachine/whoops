# This class is meant to be overwritten in host applications
#
# Authorized Service Lookups interact with filters to limit the
# services which a user is allowed to see. This allows host
# applications to more easily implement authorization.
#
# For example, if your Whoops installation is used by many different
# teams, but you don't want the teams to see each others' data, you
# could create a mapping between the team members' email addresses and
# the services they're allowed to see.
#
# Since filters are used when viewing events or sending notifications,
# the authorized service lookup allows you to modify the filters to
# prevent the unauthorized services from being seen
class Whoops::AuthorizedServiceLookup

  # @param key the value used to look up authorized services
  def initialize(key)
    @key = key
  end

  # if there are services given, then show all services
  # however, if we're looking at authorized services, then "all
  # services" means "all authorized services"
  #
  # if there is a filter on service then only allow authorized
  # services
  # 
  # one thing to note is that if both services and authorized_services
  # are blank, then no filter will be applied to service at all
  def filter_authorized(services)
    matches = services.select{ |s| service_authorized?(s) }
    matches.empty? ? authorized_services : matches
  end

  # Overwrite this in your subclasses if you want to implement
  # authorized services
  def authorized_services
    []
  end

  def service_authorized?(service)
    authorized_services.blank? || /^(#{authorized_services.join("|")})/ =~ service
  end
end
