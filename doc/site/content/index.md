--- 
title: Whoops
---

## Application Logging

Whoops is a free, self-hosted tool for logging application events like
errors or background worker completion. Whoops might be right for you
if you need to:

* Log arbitrary events, not just errors
* Search events
* Get notified of new events
* Store events behind a firewall

[Learn more about Whoops's features](/whoops-server).

## Get Started in 60 Seconds on Heroku 

To create a Whoops server, run the following: 

```
git clone https://github.com/flyingmachine/whoops-bootstrap.git
cd whoops-bootstrap
heroku create --stack bamboo-ree-1.8.7
heroku addons:add mongolab:starter
git push heroku master
```

Now visit the URL printed after the `heroku create` step.

You can also follow more
[detailed  instructions](/whoops-server#Setup). for starting with a
fresh Rails app.

To start logging exceptions in a Rails app:

1. Add `whoops_rails_logger` to your Gemfile.
2. Create `config/whoops_logger.yml`
3. Add something like the following to whoops_logger.yml:

```
production:
  host: precious-bert-reynolds-mustache.heroku.com
```

## Git Repos

* [Whoops Server](https://github.com/flyingmachine/whoops>)
* [Whoops Logger](https://github.com/flyingmachine/whoops_logger)
* [Whoops Rails Logger](https://github.com/flyingmachine/whoops_rails_logger>)

## Demos

* [Whoops Demo](http://whoops-example.heroku.com)
* [Example Rails site which sends logs to Whoops](http://whoops-rails-logger-example.heroku.com/)

## Alternatives

* [Airbrake (the app formerly known as Hoptoad)](http://airbrakeapp.com/pages/home)
* [papertrail](https://papertrailapp.com/)
* [Graylog2](http://graylog2.org/)
* [errbit](https://github.com/jdpace/errbit)
