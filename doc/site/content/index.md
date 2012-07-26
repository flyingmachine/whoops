--- 
title: Whoops
---

## What is Whoops?

Whoops is a free, open-source, self-hosted logging system. It consists
of a Rails engine (which records logs and provides an interface to
them) and a logger. The server and Ruby logger are described below,
along with comparisons to other logging systems.

## Whoops Server

The Whoops server is a Rails engine which records logs and provides an
interface to filter, search, and view them. Below are its features and
how it compares to Hoptoad:

image::./assets/dash.png["Dash", link="./assets/dash.png"]

### Log Arbitrary Events

With Airbrake, you only log exceptions. With Whoops, it's up to you to
tell the Whoops server what you're logging, be it an exception,
notification, warning, or whatever. Internally, +Whoops::EventGroup+
uses the +event_type+ field to store the event type. You can filter on
this field when viewing a listing of all events.

### Log Arbitrary Details

With many logging systems, the fields which you can log are
pre-defined. They also reflect an assumption that your error happened
within the context of handling an HTTP request. Whoops uses mongodb as
its database and this allows you to log whatever details you want. For
example, you could log the following:

``` ruby
{
  :start_time => 1310748754,
  :end_time   => 1310949834,
  :users_imported => [
    { :id => 413, :succeeded => false },
    { :id => 835, :succeeded => true },
    { :id => 894, :succeeded => true },
    { :id => 124, :succeeded => true },
  ],
}
```

This gets stored as-is in Whoops. You can also search these details, as explained below:

### Search Event Details

As far I know, you can't search Airbrake or Errbit. Graylog2 provides
search. Whoops provides two kinds of search: event detail search
within for all events within an EventGroup, and keywords search across
all events and event groups.

Below is example text you would write to search event details, and
below that is essentially the ruby code that ends up getting run by
the server.

``` ruby
details.current_user_id#in [3, 54, 532]      <1>
details.num_failures#gt 3                    <2>
details.current_user.first_name Voldemort    <3>
message !r/(yesterday|today)/                <4>
```

1. `Event.where( {:"details.current_user_id".in => [3, 54, 532]} )`
2. `Event.where( {:"details.num_failure".gt => 3} )`
3. `Event.where( {:"details.current_user.first_name" => "Voldemort"} )`
4. `Event.where( {:message => /(yesterday|today/)} )` Note that regular expressions must start with !r.
  
The general format is `key[#mongoid_method] query` . As you can see,
`query` can be a string, number, regex, or array of these values.
Hashes are allowed too. If you're not familiar with querying mongo,
you can http://www.mongodb.org/display/DOCS/Querying[read more in the
mongodb docs]. The
http://two.mongoid.org/docs/querying/criteria.html#where[Mongoid] docs are
useful as well.

### Extend the App

Since Whoops is a Rails engine, you can make changes to your base
rails app without worrying about merge difficulties when you upgrade
Whoops. For example, you could add basic HTTP authentication.

### No Users or Projects

In Airbrake, errors are assigned to projects, and access to projects is
given to users. In Whoops, there are no users, so it's not necessary
to manage access rights or even to log in. Additionally, there is no
Project model within the code or database. Instead, each EventGroup
has a +service+ field which you can filter on. Services can be
namespaced, so that if you have the services "godzilla.web" and
"godzilla.background", you can set a filter to show events related to
either service or both.

Note that you can add users and/or authentication to the base rails
app if you really want to.

### Notifications

Since Whoops doesn't have users, email notification of events is
handled by entering an email address along with a newline-separated
list of services to receive notifications for.

image:./assets/notification-rules.png["Dash",
link="./assets/notification-rules.png"]

Notifications are sent in two circumstances:

* A new kind of event is received
* An event is received for an archived event group

You must set the ActionMailer settings in your base Rails app in order
to send notifications. Additionally, you must set the "from" email
address with +Rails.application.config.whoops_sender+

### Archival

You can archive a specific event group when viewing its details page.
This prevents the event group from showing up in the event group list.

You can view archived event groups by appending +show_archived=true+
to the event group url. For example:
+http://localhost:3000/event_groups?show_archived=true+ . A more
elegant way to do this will be implemented in the future.

If a new event comes in for an event group after the event group is
archived, a notification will be sent.

### You Manage the Rails App

If you use Whoops you'll have to manage the Rails app yourself. You'll
have to set up mongodb and all that. Heroku has a
http://addons.heroku.com/mongolab[great mongodb addon] that gives you
240mb of space for free. Hoptoad doesn't require you to host or manage
anything.

Since Whoops is self-hosted, you can set it up behind your firewall.

### Installation

* create a new rails app
* add +gem "whoops"+ to your Gemfile
* run +bundle+
* add http://two.mongoid.org/docs/installation/configuration.html[+config/mongoid.yml+]
* _optional_ add +root :to => "event_groups#index"+ to your routes file to make the event group listing your home page
* add https://github.com/flyingmachine/whoops_logger[loggers] to the code you want to monitor
* ensure that your +config/application.rb+ file looks something like
the following:

``` ruby
# make sure that you're not requiring active record
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => %w(development test)))
end

module WhoopsServer
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.assets.enabled = true
    config.filter_parameters += [:password]
    # optional - only for sending email notifications
    config.whoops_sender = "whoops@yourdomain.com"
  end
end
```

### Usage

=### Filtering

.Filters
image::./assets/dash.png["Dash", link="./assets/dash.png"]

When viewing the Event Group list, you can filter by service, environment, and event type.

When you set a filter, its value is stored in a session and won't be changed until you click "reset". This is so that you won't lose your filter after, for example, viewing a specific event.

== Whoops Logger

Use Whoops Logger to send log messages to a https://github.com/flyingmachine/whoops[Whoops] server.

### Rails Gem

Please note that there's a
https://github.com/flyingmachine/whoops_rails_logger[Rails gem] which
simplifies usage in two ways:

1. You don't have to specify the location of a whoops config file; it
defaults to config/whoops.yml
2. It includes an exception logger which will handle all exceptions
within the context of a controller action.

Below are instructions for adding additional logging strategies and
using the "bare" Ruby client.

### Installation

Add +whoops_logger+ to your Gemfile

Add +WhoopsLogger.config.set(config_path)+ to your project, where +config_path+ is a path to a YAML file. The YAML file takes the following options:

----
:host
:http_open_timeout
:http_read_timeout
:port
:protocol
:proxy_host
:proxy_pass
:proxy_port
:proxy_user
:secure
----

You can also use pass a Hash to +WhoopsLogger.config.set+ instead of a path to a YAML file.

### Usage

Whoops Logger sends Messages to Whoops. Messages are created with Strategies. Below is the basic strategy found in `lib/whoops_logger/basic.rb`:

``` ruby
strategy = WhoopsLogger::Strategy.new("default::basic")

strategy.add_message_builder(:use_basic_hash) do |message, raw_data|
  message.event_type             = raw_data[:event_type]
  message.service                = raw_data[:service]
  message.environment            = raw_data[:environment]
  message.message                = raw_data[:message]
  message.event_group_identifier = raw_data[:event_group_identifier]
  message.event_time             = raw_data[:event_time] if raw_data[:event_time]
  message.details                = raw_data[:details]
end
```

To use this strategy, you would call

``` ruby
WhoopsLogger.log("default::basic", {
  :event_type             => "your_event_type",
  :service                => "your_service_name",
  :environment            => "development",
  :message                => "String to Show in Whoops Event List",
  :event_group_identifier => "String used to assign related events to a group",
  :event_time             => Time.now # Defaults to now, so you can leave this out
  :details                => "A string, hash, or array of arbitrary data"
})
```

You can create as many strategies as you need. For example, in a Rails
app, you could use a strategy for logging exceptions which occur
during a controller action (in fact
https://github.com/flyingmachine/whoops_rails_logger[there's a gem for
that]). You could use a separate strategy for logging exceptions which
occur during a background job. With controller actions, you care about
params, sessions, and that data. That data isn't even present in
background jobs, so it makes sense to use different strategies.

###= Message Builders

Each strategy consists of one or more message builders. The message builders are called in the order in which they are defined.

Internally, each Strategy stores its message builders in the array +message_builders+, and it's possible to modify that array directly if you want. For example, you might want to modify a Strategy provided by a library.

The method +add_message_builder+ is provided for convenience. Below is an example of +add_message_builder+ taken from the https://github.com/flyingmachine/whoops_rails_logger[Whoops Rails Logger]:

``` ruby
# It's not necessary to break up the strategy into 3 message builders,
# but it could help to compartmentalize related portions of message building
strategy.add_message_builder(:basic_details) do |message, raw_data|
  message.service     = self.service
  message.environment = self.environment
  message.event_type  = "exception"
  message.message     = raw_data[:exception].message
  message.event_time  = Time.now
end

strategy.add_message_builder(:details) do |message, raw_data|
  exception = raw_data[:exception]
  rack_env  = raw_data[:rack_env]
  
  details = {}
  details[:backtrace] = exception.backtrace.collect{ |line|
    line.sub(/^#{ENV['GEM_HOME']}/, '$GEM_HOME').sub(/^#{Rails.root}/, '$Rails.root')
  }

  details[:http_host]      = rack_env["HTTP_HOST"]        
  details[:params]         = rack_env["action_dispatch.request.parameters"]
  details[:controller]     = details[:params][:controller] if details[:params]
  details[:action]         = details[:params][:action]     if details[:params]
  details[:query_string]   = rack_env["QUERY_STRING"]
  details[:remote_addr]    = rack_env["REMOTE_ADDR"]
  details[:request_method] = rack_env["REQUEST_METHOD"]
  details[:server_name]    = rack_env["SERVER_NAME"]
  details[:session]        = rack_env["rack.session"]
  details[:env]            = ENV.to_hash
  message.details          = details
end

strategy.add_message_builder(:create_event_group_identifier) do |message, raw_data|
  identifier = "#{message.details[:controller]}##{message.details[:action]}"
  identifier << raw_data[:exception].backtrace.collect{|b| b.gsub(/:in.*/, "")}.join("\n")
  message.event_group_identifier = Digest::SHA1.hexdigest(identifier)
end

strategy.add_message_builder(:basic_details) do |message, raw_data|
  message.service     = self.service
  message.environment = self.environment
  message.event_type  = "exception"
  message.message     = raw_data[:exception].message
  message.event_time  = Time.now
end
```

There's a bit more about message builders in the WhoopsLogger::Strategy documentation.

#### Ignore Criteria

Sometimes you want to ignore a message instead of sending it off to
whoops. For example, you might not want to log "Record Not Found"
exceptions in Rails. If any of the ignore criteria evaluate to true,
then the message is ignored. Below is an example:

``` ruby
strategy.add_ignore_criteria(:ignore_record_not_found) do |message|
  message.message == "Record Not Found"
end

strategy.add_ignore_criteria(:ignore_dev_environment) do |message|
 message.environment == "development"
end
```

## Git Repos

* https://github.com/flyingmachine/whoops
* https://github.com/flyingmachine/whoops_logger
* https://github.com/flyingmachine/whoops_rails_logger

## Demos

* http://whoops-example.heroku.com[Example of the Whoops Rails engine]
* http://whoops-rails-logger-example.heroku.com/[Example site which sends logs to whoops]

## Alternatives

* http://airbrakeapp.com/pages/home[Airbrake (the app formerly known as Hoptoad)]
* https://papertrailapp.com/[papertrail]
* http://graylog2.org/[Graylog2]
* https://github.com/jdpace/errbit[errbit]

## TODO

* graphing
* integrate fully with Rails logger (?)
