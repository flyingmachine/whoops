source "http://rubygems.org"
gemspec

group :development do
  if RUBY_VERSION =~ /1.8/
    gem "ruby-debug"
  else
    gem "ruby-debug19"
  end
end

group :test do
  gem 'rake'
end
