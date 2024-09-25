# frozen_string_literal: true

require 'spec_helper'

describe AwtrixControl::Client do
  before do
    @client = AwtrixControl::Client.new(DEFAULT_HOST)
  end

  describe '#initialize' do
    it 'initializes instance variables' do
      expect(@client.host).to eq(DEFAULT_HOST)
      expect(@client.apps).to eq({})
    end
  end

  describe '#<<' do
    it 'adds an app instance to the client' do
      app = AwtrixControl::App.new(:test_app)
      @client << app
      actual = @client.apps[:test_app]
      expect(actual).to eq(app)
      expect(app.client).to eq(@client)
    end
  end

  describe '#[]' do
    it 'returns an app instance' do
      @client.new_app(:test_app)
      app = @client[:test_app]
      expect(app.name).to eq(:test_app)
    end

    it 'returns nil if the app does not exist' do
      app = @client[:test_app]
      expect(app).to be_nil
    end
  end

  describe '#effects' do
    it 'makes a call to the effects endpoint of the device' do
      actual = JSON.parse(@client.effects)
      expect(actual.first).to eq('Fade')
      expect_request(method: :get, path: 'effects')
    end
  end

  describe '#indicator' do
    it 'renders a white indicator by default' do
      @client.indicator(:top)
      expect_request(method: :post, path: 'indicator1', body: { color: '#ffffff' })
    end

    it 'tells the device to show a given indicator in a given color' do
      @client.indicator(:bottom, '#00FF00')
      expect_request(method: :post, path: 'indicator3', body: { color: '#00FF00' })
    end

    it 'works with shorthand color symbols' do
      @client.indicator(:top, :red)
      expect_request(method: :post, path: 'indicator1', body: { color: '#ff0000' })
    end
  end

  context 'with effects' do
    it 'renders a blinking indicator' do
      @client.indicator(:center, :red, effect: :blink)
      expect_request(method: :post, path: 'indicator2', body: { color: '#ff0000', blink: 500 })
    end

    it 'renders a pulsing indicator' do
      @client.indicator(:center, :red, effect: :pulse)
      expect_request(method: :post, path: 'indicator2', body: { color: '#ff0000', fade: 2000 })
    end

    it 'renders a blinking indicator with a custom frequency' do
      @client.indicator(:center, :red, effect: :blink, frequency: 1000)
      expect_request(method: :post, path: 'indicator2', body: { color: '#ff0000', blink: 1000 })
    end

    it 'renders a pulsing indicator with a custom frequency' do
      @client.indicator(:center, :red, effect: :pulse, frequency: 5000)
      expect_request(method: :post, path: 'indicator2', body: { color: '#ff0000', fade: 5000 })
    end
  end

  describe '#loop' do
    it 'makes a call to the loop endpoint of the device' do
      actual = @client.loop
      expect(actual).to eq({ "Hello" => 1, "Time" => 0, "World" => 2 })
      expect_request(method: :get, path: 'loop')
    end
  end

  describe '#new_app' do
    it 'instantiates a new app and adds it to the client' do
      @client.new_app('test_app')
      actual = @client.apps['test_app']
      expect(actual.name).to eq('test_app')
      expect(actual.payload).to eq({})
    end

    it 'overwrites an existing app' do
      @client.new_app('test_app')
      second_app = @client.new_app('test_app')
      actual = @client.apps['test_app']
      expect(actual).to eq(second_app)
    end
  end

  describe '#notify' do
    it 'makes a call to the notify endpoint of the device' do
      @client.notify('test_notification')
      expect_request(method: :post, path: 'notify', body: { text: 'test_notification' })
    end
  end

  describe '#power' do
    it 'makes a call to the power endpoint of the device' do
      @client.power(true)
      expect_request(method: :post, path: 'power', body: { power: true })
    end
  end

  describe '#remove_indicator' do
    it 'removes an indicator from the device' do
      @client.remove_indicator(:top)
      expect_request(method: :post, path: 'indicator1', body: { color: '#000000' })
    end
  end

  describe '#remove_indicators' do
    it 'removes all indicators from the device' do
      @client.remove_indicators
      expect_request(method: :post, path: 'indicator1', body: { color: '#000000' })
      expect_request(method: :post, path: 'indicator2', body: { color: '#000000' })
      expect_request(method: :post, path: 'indicator3', body: { color: '#000000' })
    end
  end

  describe '#reset' do
    it 'makes the device sleep for 1 second' do
      @client.reset
      expect_request(method: :post, path: 'sleep', body: { sleep: 1 })
    end
  end

  describe '#rtttl' do
    it 'makes a call to the rtttl endpoint of the device' do
      @client.rtttl('test_rtttl')
      expect_request(method: :post, path: 'rtttl', body: '"test_rtttl"')
    end
  end

  describe '#screen' do
    it 'makes a call to the screen endpoint of the device' do
      actual = JSON.parse(@client.screen)
      expect(actual).to start_with(0, 0, 0, 0, 0)
      expect_request(method: :get, path: 'screen')
    end
  end

  describe '#sleep' do
    it 'makes the device sleep for a number of seconds' do
      @client.sleep(5)
      expect_request(method: :post, path: 'sleep', body: { sleep: 5 })
    end

    it 'makes the device sleep indefinitely when no seconds are provided' do
      @client.sleep
      expect_request(method: :post, path: 'sleep', body: {})
    end
  end

  describe '#sound' do
    it 'makes a call to the sound endpoint of the device' do
      @client.sound('test_sound')
      expect_request(method: :post, path: 'sound', body: { sound: 'test_sound' })
    end
  end

  describe '#stats' do
    it 'makes a call to the status endpoint of the device' do
      actual = JSON.parse(@client.stats)["version"]
      expect(actual).to eq('0.96')
      expect_request(method: :get, path: 'stats')
    end
  end

  describe '#transitions' do
    it 'makes a call to the transitions endpoint of the device' do
      actual = JSON.parse(@client.transitions).first
      expect(actual).to eq('Random')
      expect_request(method: :get, path: 'transitions')
    end
  end

  describe '#delete_app' do
    it 'deletes an app from the device' do
      app = AwtrixControl::App.new('test_app')
      @client << app
      @client.delete_app(app)
      expect(@client.apps).to eq({})
      expect_request(method: :post, path: 'custom?name=test_app', body: {})
    end

    it 'deletes an app by name' do
      app = AwtrixControl::App.new('test_app')
      @client << app
      @client.delete_app('test_app')
      expect(@client.apps).to eq({})
      expect_request(method: :post, path: 'custom?name=test_app', body: {})
    end
  end


  describe '#delete_all_apps' do
    it 'deletes all apps from the device and client, even if they do not match' do
      app1 = AwtrixControl::App.new('test_app1')
      @client << app1
      @client.delete_all_apps
      expect_request(method: :get, path: 'loop')
      # The loop endpoint is mocked with the following apps:
      expect_request(method: :post, path: 'custom?name=Time' )
      expect_request(method: :post, path: 'custom?name=Hello')
      expect_request(method: :post, path: 'custom?name=World')
      expect(@client.apps).to eq({})
    end
  end

  def expect_request(method:, path:, host: DEFAULT_HOST, body: {})
    expect(WebMock)
      .to have_requested(method, "http://#{host}/api/#{path}")
            .with(body: body)
  end

  describe '#push_app' do
    it 'pushes an app to the device' do
      app = AwtrixControl::App.new('test_app')
      @client.push_app(app)
      expect_request(method: :post,
                     path: 'custom?name=test_app',
                     body: { "name": "test_app" }.merge(app.default_payload))
    end
  end
end
