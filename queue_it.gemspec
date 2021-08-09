$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem"s version:
require "queue_it/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name          = "queue-it"
  s.version       = QueueIt::VERSION
  s.authors       = ["Platanus", "Gabriel Lyon"]
  s.email         = ["rubygems@platan.us", "gabriel@platan.us"]
  s.homepage      = "https://github.com/platanus/queue_it/master"
  s.summary       = ""
  s.description   = ""
  s.license       = "MIT"

  s.files = `git ls-files`.split($/).reject { |fn| fn.start_with? "spec" }
  s.bindir = "exe"
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 6.0"
  s.add_development_dependency "annotate", "~> 3.0"
  s.add_development_dependency "bundler", "~> 2.2.15"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "factory_bot_rails"
  s.add_development_dependency "faker"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "pg"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency "rspec_junit_formatter"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "rubocop", "~> 1.9"
  s.add_development_dependency "rubocop-rails"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "sqlite3"
end
