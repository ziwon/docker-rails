# This has to come first
require_relative "./support/rails"

require "capybara/rails"
require "capybara/minitest"

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  # Make `assert_*` methods behave like Minitest assertions
  include Capybara::Minitest::Assertions

  # Reset sessions and driver between tests
  teardown do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

# Load everything else from test/support
Dir[File.expand_path("support/**/*.rb", __dir__)].each { |rb| require(rb) }
