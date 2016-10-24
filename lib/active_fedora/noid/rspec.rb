RSpec.configure do |config|
  config.before(:suite) do
    ActiveFedora::Noid.configure do |noid_config|
      noid_config.minter_class = ActiveFedora::Noid::Minter::File
    end
  end
end
