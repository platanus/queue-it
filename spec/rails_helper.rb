require 'simplecov'
require 'coveralls'
require 'faker'
require "shoulda/matchers"

formatters = [SimpleCov::Formatter::HTMLFormatter, Coveralls::SimpleCov::Formatter]
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter::new(formatters)

SimpleCov.start do
  add_filter do |src|
    r = [
      src.filename =~ /lib/,
      src.filename =~ /models/,
      src.filename =~ /controllers/
    ].uniq
    r.count == 1 && r.first.nil?
  end

  add_filter "engine.rb"
  add_filter "spec.rb"
end

ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../spec/dummy/config/environment', __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "pry"
require "spec_helper"
require "rspec/rails"
require "factory_bot_rails"

Dir[::QueueIt::Engine.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.fixture_path = "#{::QueueIt::Engine.root}/spec/assets"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.include FactoryBot::Syntax::Methods
  config.include ActionDispatch::TestProcess
  config.include TestHelpers
end
