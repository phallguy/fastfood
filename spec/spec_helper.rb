require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|

  config.use_transactional_fixtures = false
  config.order = "random"


  config.fixture_path = Rails.root.join "spec", "fixtures"
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.filter_run focus: true
  config.filter_run_excluding :broken => true
  config.run_all_when_everything_filtered = true

  config.before(:each)  { GC.disable }
  config.after(:each)   { GC.enable }

  config.before(:suite) do
    FactoryGirl.reload
  end

end

