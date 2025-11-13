RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.definition_file_paths = Dir[Rails.root.join('spec/contexts/*/factories')]
    FactoryBot.find_definitions
  end
end
