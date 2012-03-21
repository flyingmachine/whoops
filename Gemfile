source "http://rubygems.org"
gemspec

platform :ruby do
  gem 'bson_ext'
end

group :development do
  unless ENV["CI"]
    gem 'ruby-debug-base19', '0.11.23' if RUBY_VERSION.include? '1.9.1'
    gem 'ruby-debug19', :platforms => :ruby_19
    gem 'ruby-debug', :platforms => :mri_18
  end
end

group :test do
  gem 'rake'
end
