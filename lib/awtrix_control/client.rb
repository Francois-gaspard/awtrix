# frozen_string_literal: true

require_relative 'request'

module AwtrixControl
  # Initialize 1 client per awtrix 3 device.
  # The client is used to manage the apps on the device.
  # The apps are stored in a registry within the client, so you can refer to them by name.
  # Note that there is no synchronization between clients or between client and device.
  # E.g. If you instantiate 2 clients for the same device, they will not be aware of each other and apps could collide,
  #  or race conditions could occur.
  class Client
    include AwtrixControl::Request

    INDICATOR_INDEX = { top: 1, center: 2, bottom: 3 }.freeze

    attr_reader :apps, :host

    # @param host [String] the IP address or hostname of the Awtrix device
    def initialize(host)
      @host = host
      @apps = {}
    end

    def <<(app)
      @apps[app.name] = app
      app.client = self
    end

    def [](name)
      @apps[name]
    end

    def effects
      get('effects')
    end

    # @param location [Symbol] The location of the indicator to render.
    #   Must be a key in INDICATOR_INDEX (:top, :center, :bottom)
    # @param color [String, Array, Symbol] the color to set the indicator to.
    #  String: A HEX string representing the color
    #  Array: An array of 3 integers representing the RGB values of the color
    #  Symbol: A symbol representing the color. Must be a key in COLOR_MAPPINGS
    def indicator(location, color = :white, effect: nil, frequency: nil)
      payload = {}
      payload[:color] = AwtrixControl::COLOR_MAPPINGS[color] || color
      payload[:blink] = frequency || 500 if effect == :blink
      payload[:fade] = frequency || 2000 if effect == :pulse
      index = INDICATOR_INDEX[location]
      post("indicator#{index.to_i}", payload)
    end

    # @return [Hash] the current loop state, as a Hash of apps and their current index.
    # @example
    #  client.loop
    #  { "Hello" => 1, "Time" => 0, "World" => 2 }
    def loop
      JSON.parse(get('loop'))
    end

    def new_app(name, **payload)
      app = App.new(name,  payload: payload, client: self)
      self << app
      app
    end

    def notify(text, **payload)
      post('notify', { text: }.merge(payload))
    end

    # @param switch [Boolean] the power state to set
    # Note that this only turns off the display, not the device itself
    def power(switch)
      post('power', { power: switch })
    end

    def remove_indicator(location)
      indicator(location, :black)
    end

    def remove_indicators
      INDICATOR_INDEX.each_key { |location| remove_indicator(location) }
    end

    def reset
      sleep(1)
    end

    def rtttl(rtttl_string)
      post('rtttl', rtttl_string)
    end

    def screen
      get('screen')
    end

    # @param seconds [Integer] the number of seconds to sleep
    # If no seconds are provided, the device will sleep indefinitely
    def sleep(seconds = 0)
      payload = (seconds.to_i > 0 ? { sleep: seconds.to_i } : {})
      post('sleep', **payload)
    end

    def sound(name)
      post('sound', { sound: name })
    end

    def stats
      get('stats')
    end

    def transitions
      get('transitions')
    end

    def delete_app(app)
      name = app.is_a?(App) ? app.name : app
      post('custom', {}, { name: })
      @apps.delete(name)
    end

    def delete_all_apps
      loop.each_key { |app| delete_app(app) }
      @apps = {}
    end

    # Push an app to the device, or updates an existing one
    def push_app(app)
      post('custom', { name: app.name }.merge(app.payload), { name: app.name })
    end
  end
end
