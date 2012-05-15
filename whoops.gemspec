# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "whoops"
  s.authors = ["Daniel Higginbotham"]
  s.summary = "A Rails engine which receives logs and provides an interface for them"
  s.description = "A Rails engine which receives logs and provides an interface for them"
  s.homepage = "http://www.whoopsapp.com"
  s.files = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.asciidoc"]
  s.version = "0.2.3"

  s.add_dependency('rails', '~>3')
  s.add_dependency('sass')
  s.add_dependency('haml')
  s.add_dependency('mongo')
  s.add_dependency('mongoid', '~>2.4')
  s.add_dependency('kaminari')

  s.add_development_dependency('rspec-rails')
  s.add_development_dependency('fabrication')
  s.add_development_dependency('faker')
  s.add_development_dependency("capybara", ">= 0.4.0")
end
