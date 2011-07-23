# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "whoops"
  s.authors = ["Daniel Higginbotham"]
  s.summary = "A logger"
  s.description = "A logger"
  s.files = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.asciidoc"]
  s.version = "0.1.3"
  
  s.add_dependency('rake', '0.8.7')
  s.add_dependency('rails', '~>3')
  s.add_dependency('sass')
  s.add_dependency('haml')
  s.add_dependency('mongo')
  s.add_dependency('bson_ext')
  s.add_dependency('mongoid', '2.0.1')
  s.add_dependency('will_paginate', '~> 3.0.pre2')
  
  s.add_development_dependency('rspec-rails')
  s.add_development_dependency('mocha')
  s.add_development_dependency('fabrication')
  s.add_development_dependency('ruby-debug')
  s.add_development_dependency('faker')
  s.add_development_dependency("capybara", ">= 0.4.0")
end