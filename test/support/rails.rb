ENV["RAILS_ENV"] ||= "test"
require_relative "../../config/environment"
require "rails/test_help"

Webdrivers.logger.level = ::Logger::Severity::DEBUG

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alpha order.
  fixtures :all
end
