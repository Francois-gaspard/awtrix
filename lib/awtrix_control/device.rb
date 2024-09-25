# frozen_string_literal: true

require_relative 'request'

module AwtrixControl
  # The Device class is used to manage the apps on an Awtrix device.
  # The apps are stored in a registry within the device, so you can refer to them by name.
  # Note that there is no synchronization between devices or between device and device.
  # E.g. If you instantiate 2 devices for the same device, they will not be aware of each other and apps could collide,
  #  or race conditions could occur.
  class Device
    include AwtrixControl

    INDICATOR_INDEX = { top: 1, center: 2, bottom: 3 }.freeze

    attr_reader :apps, :host

    # Initializes a new Device instance.
    #
    # @param host [String] the IP address or hostname of the Awtrix device
    def initialize(host)
      @host = host
      @apps = {}
    end

    # Adds an app to the device.
    #
    # @param app [App] the app to add
    # @return [App] the added app
    def <<(app)
      @apps[app.name] = app
      app.device = self unless app.device == self
      app
    end

    # Retrieves an app by name.
    #
    # @param name [String] the name of the app
    # @return [App, nil] the app if found, otherwise nil
    def [](name)
      @apps[name]
    end

    # Retrieves the effects from the device.
    #
    # @return [Hash] the effects
    def effects
      get('effects')
    end

    # Sets the indicator on the device.
    #
    # @param location [Symbol] The location of the indicator to render.
    #   Must be a key in INDICATOR_INDEX (:top, :center, :bottom)
    # @param color [String, Array, Symbol] the color to set the indicator to.
    #  String: A HEX string representing the color
    #  Array: An array of 3 integers representing the RGB values of the color
    #  Symbol: A symbol representing the color. Must be a key in COLOR_MAPPINGS
    # @param effect [Symbol, nil] the effect to apply (e.g., :blink, :pulse)
    # @param frequency [Integer, nil] the frequency of the effect
    def indicator(location, color = :white, effect: nil, frequency: nil)
      payload = {}
      payload[:color] = AwtrixControl::COLOR_MAPPINGS[color] || color
      payload[:blink] = frequency || 500 if effect == :blink
      payload[:fade] = frequency || 2000 if effect == :pulse
      index = INDICATOR_INDEX[location]
      post("indicator#{index.to_i}", payload)
    end

    # Retrieves the current loop state.
    #
    # @return [Hash] the current loop state, as a Hash of apps and their current index.
    # @example
    #  device.loop
    #  { "Hello" => 1, "Time" => 0, "World" => 2 }
    def loop
      JSON.parse(get('loop'))
    end

    # Creates a new app and adds it to the device.
    #
    # @param name [String] the name of the app
    # @param payload [Hash] additional payload for the app
    # @return [App] the created app
    def new_app(name, **payload)
      app = payload.empty? ? App.new(name, device: self) : App.new(name, payload:, device: self)
      self << app
      app
    end

    # Sends a notification to the device.
    #
    # @param text [String] the notification text
    # @param payload [Hash] additional payload for the notification
    def notify(text, **payload)
      payload[:color] = normalize_color(payload[:color] || :white)
      post('notify', { text: }.merge(payload))
    end

    # Sets the power state of the device.
    #
    # @param switch [Boolean] the power state to set
    # Note that this only turns off the display, not the device itself
    def power(switch)
      post('power', { power: switch })
    end

    # Removes an indicator from the device.
    #
    # @param location [Symbol] the location of the indicator to remove
    def remove_indicator(location)
      indicator(location, :black)
    end

    # Removes all indicators from the device.
    def remove_indicators
      INDICATOR_INDEX.each_key { |location| remove_indicator(location) }
    end

    # Resets the device.
    def reset
      sleep(1)
    end

    # Plays an RTTTL string on the device.
    #
    # @param rtttl_string [String] the RTTTL string to play
    def rtttl(rtttl_string)
      post('rtttl', rtttl_string)
    end

    # Retrieves the screen state from the device.
    #
    # @return [Hash] the screen state
    def screen
      get('screen')
    end

    # Puts the device to sleep.
    #
    # @param seconds [Integer] the number of seconds to sleep
    # If no seconds are provided, the device will sleep indefinitely
    def sleep(seconds = 0)
      payload = (seconds.to_i > 0 ? { sleep: seconds.to_i } : {})
      post('sleep', **payload)
    end

    # Plays a sound on the device.
    #
    # @param name [String] the name of the sound to play
    def sound(name)
      post('sound', { sound: name })
    end

    # Retrieves the device statistics.
    #
    # @return [Hash] the device statistics
    def stats
      get('stats')
    end

    # Retrieves the transitions from the device.
    #
    # @return [Hash] the transitions
    def transitions
      get('transitions')
    end

    # Deletes an app from the device.
    #
    # @param app_name [String, Symbol] the app name to delete
    def delete_app(app_name)
      post('custom', {}, { name: app_name })
      @apps.delete(app_name)
    end

    # Deletes all apps from the device.
    def delete_all_apps
      loop.each_key { |app_name| delete_app(app_name) }
      @apps = {}
    end

    # Pushes an app to the device, or updates an existing one.
    #
    # @param app_name [Symbol, String] the app name to push
    def push_app(app_name)
      registered_app = @apps[app_name]
      return unless registered_app

      post('custom',
           { name: registered_app.name }.merge(registered_app.payload),
           { name: registered_app.name })
    end
  end
end
