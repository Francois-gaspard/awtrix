require 'bundler/setup'
Bundler.setup

require 'awtrix_control'
require 'webmock/rspec'

# Disable external requests
WebMock.disable_net_connect!(allow_localhost: true)

DEFAULT_HOST = '1.1.1.1'

# Global stubs
RSpec.configure do |config|
  config.before(:each) do
    stub_request(:get, %r{http://#{DEFAULT_HOST}/api/.*})
      .to_return do |request|
      path = request.uri.path.split('/').last
      file_path = File.join('spec', 'fixtures', "get_#{path}.json")
      {
        status: 200,
        body: File.read(file_path),
        headers: { 'Content-Type' => 'application/json' }
      }
    end

    stub_request(:post, %r{http://#{DEFAULT_HOST}/api/.*})
      .to_return(
        status: 200,
        body: "OK",
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end
