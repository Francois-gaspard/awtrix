# frozen_string_literal: true

require_relative 'request'

module AwtrixControl
  class App
    include AwtrixControl
    attr_accessor :name, :payload

    # Payload attributes with their types and camelCase keys:
    ATTRIBUTES = {
      text: { key: 'text' },
      text_case: { key: 'textCase', default: 0 },
      top_text: { key: 'topText', default: false },
      text_offset: { key: 'textOffset', default: 0 },
      center_text: { key: 'center', default: true },
      text_color: { key: 'color' },
      text_gradient: { key: 'gradient' },
      blink_text: { key: 'blinkText' },
      fade_text: { key: 'fadeText' },
      background_color: { key: 'background' },
      rainbow_effect: { key: 'rainbow' },
      icon: { key: 'icon' },
      push_icon: { key: 'pushIcon', default: 0 },
      repeat_text: { key: 'repeat', default: -1 },
      display_duration: { key: 'duration', default: 5 },
      hold_notification: { key: 'hold', default: false },
      sound: { key: 'sound' },
      rtttl_sound: { key: 'rtttl' },
      loop_sound: { key: 'loopSound', default: false },
      bar_chart: { key: 'bar' },
      line_chart: { key: 'line' },
      auto_scale: { key: 'autoScale', default: true },
      progress_bar: { key: 'progress', default: -1 },
      progress_bar_color: { key: 'progressC', default: -1 },
      progress_bar_background_color: { key: 'progressBC', default: -1 },
      position: { key: 'pos' },
      draw_commands: { key: 'draw' },
      lifetime: { key: 'lifetime', default: 0 },
      lifetime_mode: { key: 'lifetimeMode', default: 0 },
      stack_notifications: { key: 'stack', default: true },
      wakeup_display: { key: 'wakeup', default: false },
      disable_scroll: { key: 'noScroll', default: false },
      forward_clients: { key: 'clients' },
      scroll_speed: { key: 'scrollSpeed', default: 100 },
      background_effect: { key: 'effect' },
      background_effect_settings: { key: 'effectSettings' },
      save_app: { key: 'save' },
      overlay_effect: { key: 'overlay' }
    }.freeze

    LIFETIME_MODE_OPTIONS = {
      destroy: 0,
      stale: 1
    }.freeze

    PUSH_ICON_OPTIONS = {
      fixed: 0,
      scroll_once: 1,
      loop: 2,
    }.freeze

    TEXT_CASES = {
      default: 0,
      upcase: 1,
      as_is: 2
    }.freeze

    # Initializes a new App instance.
    #
    # @param name [Symbol, String] the name of the app. Must be unique within the device, or the app will be overwritten
    # @param payload [Hash, nil] the payload for the app
    # @param device [Device, nil] the device to associate the app with
    def initialize(name, payload: nil, device: nil)
      @name = name
      device << self if device
      @payload = payload || default_payload
    end

    # Pushes the app to the associated device.
    def push
      return if @device.nil?
      @device.push_app(self)
    end

    # Define getters for each attribute in ATTRIBUTES.
    ATTRIBUTES.each do |method_name, options|
      awtrix_attribute = options[:key]
      define_method(method_name) do
        payload[awtrix_attribute]
      end
    end

    # Sets the autoscale attribute.
    #
    # @param value [Boolean] whether to autoscale the bar or line chart.
    def autoscale=(value)
      @payload[method_to_awtrix_key(:auto_scale)] = !!value
    end

    # Sets the background color.
    #
    # @param value [String, Symbol, Array<Integer>] the color to set the background to
    # String: A hex color code
    # Symbol: A color name. Must be a key in COLOR_MAPPINGS
    # Array: An array of 3 integers representing the RGB values of the color
    def background_color=(value)
      @payload[method_to_awtrix_key(:background_color)] = normalize_color(value)
    end

    # Sets the background effect.
    #
    # @param value [String] the effect to apply to the background
    def background_effect=(value)
      @payload[method_to_awtrix_key(:background_effect)] = value
    end

    # Sets the background effect settings.
    #
    # @param value [Hash] the settings for the background effect
    def background_effect_settings=(value)
      @payload[method_to_awtrix_key(:background_effect_settings)] = value
    end

    # Sets the bar chart values.
    #
    # @param value [Array<Integer>] an array of integers to represent each bar
    def bar_chart=(value)
      @payload[method_to_awtrix_key(:bar_chart)] = value
    end

    # Sets the blink text frequency.
    #
    # @param value [Integer] the frequency (in ms) at which the text should blink
    def blink_text=(value)
      @payload[method_to_awtrix_key(:blink_text)] = value.to_i
    end

    # Gets the blink text frequency.
    #
    # @return [Integer] the frequency (in ms) at which the text should blink
    def blink_text
      @payload[method_to_awtrix_key(:blink_text)].to_i
    end

    # Sets whether to center the text.
    #
    # @param value [Boolean] whether to center the text
    def center_text=(value)
      @payload[method_to_awtrix_key(:center_text)] = value
    end

    # Returns the default payload.
    #
    # @return [Hash] the default payload
    def default_payload
      @default_payload ||=
        ATTRIBUTES.each_with_object({}) do |(method_name, options), hash|
        hash[options[:key]] = options[:default] if options.key?(:default)
      end
    end

    # Deletes the app from the associated device.
    def delete
      @device&.delete_app(self)
    end

    # Gets the associated device.
    #
    # @return [Device, nil] the associated device
    def device
      @device
    end

    # Sets the associated device.
    #
    # @param new_device [Device] the new device to associate the app with
    def device=(new_device)
      @device.delete_app(self) if @device
      @device = new_device

      new_device << self
    end

    # Sets whether to disable text scrolling.
    #
    # @param value [Boolean] whether to disable text scrolling
    def disable_scroll=(value)
      @payload[method_to_awtrix_key(:disable_scroll)] = !!value
    end

    # Sets the display duration.
    #
    # @param value [Integer] for how long (in seconds) the notification should be shown
    def display_duration=(value)
      @payload[method_to_awtrix_key(:display_duration)] = value.to_i
    end

    # Sets the drawing commands.
    #
    # @param value [Array] array of drawing instructions
    def draw_commands=(value)
      @payload[method_to_awtrix_key(:draw_commands)] = value
    end

    # Sets the fade text frequency.
    #
    # @param value [Integer] the frequency (in ms) at which the text should fade in and out
    def fade_text=(value)
      @payload[method_to_awtrix_key(:fade_text)] = value.to_i
    end

    # Gets the fade text frequency.
    #
    # @return [Integer] the frequency (in ms) at which the text should fade in and out
    def fade_text
      @payload[method_to_awtrix_key(:fade_text)].to_i
    end

    # Sets the forward clients.
    #
    # @param value [Array<String>] an array of IP addresses of other devices to forward notifications to
    def forward_clients=(value)
      @payload[method_to_awtrix_key(:forward_clients)] = value
    end

    # Sets whether to hold the notification.
    #
    # @param value [Boolean] whether to hold the notification
    def hold_notification=(value)
      @payload[method_to_awtrix_key(:hold_notification)] = !!value
    end

    # Sets the icon.
    #
    # @param value [String] the icon ID or filename (without extension) to display on the app
    def icon=(value)
      @payload[method_to_awtrix_key(:icon)] = value
    end

    # Sets the lifetime.
    #
    # @param value [Integer] the time in seconds after which the app should be removed if no update is received
    def lifetime=(value)
      @payload[method_to_awtrix_key(:lifetime)] = value.to_i
    end

    # Sets the lifetime mode.
    #
    # @param value [Symbol, Integer] the lifetime mode to use
    # Symbol options: :destroy, :stale
    # Integer options: 0, 1
    def lifetime_mode=(value)
      @payload[method_to_awtrix_key(:lifetime_mode)] = LIFETIME_MODE_OPTIONS[value] || value
    end

    # Gets the lifetime mode.
    #
    # @return [Symbol, nil] the lifetime mode
    def lifetime_mode
      LIFETIME_MODE_OPTIONS.key(@payload[method_to_awtrix_key(:lifetime_mode)])
    end

    # Sets the line chart values.
    #
    # @param value [Array<Integer>] an array of integers to represent the line chart
    def line_chart=(value)
      @payload[method_to_awtrix_key(:line_chart)] = value
    end

    # Sets whether to loop the sound.
    #
    # @param value [Boolean] whether to loop the sound as long as the notification is shown
    def loop_sound=(value)
      @payload[method_to_awtrix_key(:loop_sound)] = !!value
    end

    # Sets the overlay effect.
    #
    # @param value [String] the effect to apply as an overlay
    def overlay_effect=(value)
      @payload[method_to_awtrix_key(:overlay_effect)] = value
    end

    # Sets the position of the app in the loop.
    #
    # @param value [Integer] the position of the app in the loop (starting at 0)
    def position=(value)
      @payload[method_to_awtrix_key(:position)] = value
    end

    # Sets the progress bar value.
    #
    # @param value [Integer] a value between 0 and 100 to set the progress bar to
    def progress_bar=(value)
      @payload[method_to_awtrix_key(:progress_bar)] = value.to_i
    end

    # Sets the progress bar background color.
    #
    # @param value [String, Symbol, Array<Integer>] the color to set the progress bar background to
    def progress_bar_background_color=(value)
      @payload[method_to_awtrix_key(:progress_bar_background_color)] = normalize_color(value)
    end

    # Sets the progress bar color.
    #
    # @param value [String, Symbol, Array<Integer>] the color to set the progress bar to
    def progress_bar_color=(value)
      @payload[method_to_awtrix_key(:progress_bar_color)] = normalize_color(value)
    end

    # Sets the push icon behavior.
    #
    # @param value [Symbol, Integer] a symbol defining the push icon behavior:
    # :fixed, :scroll_once, :loop
    #   Or an integer between 0 and 2 representing the above symbols
    def push_icon=(value)
      @payload[method_to_awtrix_key(:push_icon)] = PUSH_ICON_OPTIONS[value] || value
    end

    # Gets the push icon behavior.
    #
    # @return [Symbol, nil] the push icon behavior
    def push_icon
      PUSH_ICON_OPTIONS.key(@payload[method_to_awtrix_key(:push_icon)])
    end

    # Sets whether to enable the rainbow effect.
    #
    # @param value [Boolean] whether to enable the rainbow effect
    def rainbow_effect=(value)
      @payload[method_to_awtrix_key(:rainbow_effect)] = !!value
    end

    # Sets the repeat text value.
    #
    # @param value [Integer] the number of times to repeat the text
    def repeat_text=(value)
      @payload[method_to_awtrix_key(:repeat_text)] = value.to_i
    end

    # Sets the RTTTL sound.
    #
    # @param value [String] a RTTTL string to play as a sound
    def rtttl_sound=(value)
      @payload[method_to_awtrix_key(:rtttl_sound)] = value
    end

    # Sets whether to save the app.
    #
    # @param value [Boolean] whether to save the app into flash memory
    def save_app=(value)
      @payload[method_to_awtrix_key(:save_app)] = !!value
    end

    # Sets the scroll speed.
    #
    # @param value [Integer] the new scroll speed, as a percentage of the original scroll speed
    def scroll_speed=(value)
      @payload[method_to_awtrix_key(:scroll_speed)] = value.to_i
    end

    # Sets whether to stack notifications.
    #
    # @param value [Boolean] whether to stack the notification
    def stack_notifications=(value)
      @payload[method_to_awtrix_key(:stack_notifications)] = !!value
    end

    # Sets the sound.
    #
    # @param value [String] the filename of the RTTTL ringtone file or the 4-digit number of the MP3
    def sound=(value)
      @payload[method_to_awtrix_key(:sound)] = value
    end

    # Sets the text.
    #
    # @param value [String] the text to display
    def text=(value)
      @payload[method_to_awtrix_key(:text)] = value
    end

    # Sets the text case.
    #
    # @param value [Symbol, Integer] the text case to use
    # Symbol options: :default, :upcase, :as_is
    # Integer options: 0, 1, 2
    def text_case=(value)
      @payload[method_to_awtrix_key(:text_case)] = TEXT_CASES[value] || value
    end

    # Gets the text case.
    #
    # @return [Symbol, nil] the text case
    def text_case
      TEXT_CASES.key(@payload[method_to_awtrix_key(:text_case)])
    end

    # Sets the text color.
    #
    # @param value [String, Symbol, Array<Integer>] the color to set the text to
    # String: A hex color code
    # Symbol: A color name. Must be a key in COLOR_MAPPINGS
    # Array: An array of 3 integers representing the RGB values of the color
    def text_color=(value)
      @payload[method_to_awtrix_key(:text_color)] = normalize_color(value)
    end

    # Sets the text gradient.
    #
    # @param gradient [Hash] a hash with keys :from and :to, each with a color value
    # String: A hex color code
    # Symbol: A color name. Must be a key in COLOR_MAPPINGS
    # Array: An array of 3 integers representing the RGB values of the color
    def text_gradient=(gradient)
      from = normalize_color(gradient[:from])
      to = normalize_color(gradient[:to])
      @payload[method_to_awtrix_key(:text_gradient)] = [from, to]
    end

    # Gets the text gradient.
    #
    # @return [Hash] a hash with keys :from and :to, each with a color value
    def text_gradient
      raw_gradient = @payload[method_to_awtrix_key(:text_gradient)]
      return { from: nil, to: nil } if raw_gradient.nil?
      {
        from: raw_gradient[0],
        to: raw_gradient[1]
      }
    end

    # Sets the text offset.
    #
    # @param value [Integer] the offset for the x position of a starting text
    def text_offset=(value)
      @payload[method_to_awtrix_key(:text_offset)] = value
    end

    # Sets whether to draw the text on top.
    #
    # @param value [Boolean] whether to draw the text on top
    def top_text=(value)
      @payload[method_to_awtrix_key(:top_text)] = value
    end

    # Sets the text case to uppercase.
    def upcase
      @payload[method_to_awtrix_key(:text_case)] = 1
    end

    # Sets whether to wake up the display for the notification.
    #
    # @param value [Boolean] whether to wake up the display for the notification
    def wakeup_display=(value)
      @payload[method_to_awtrix_key(:wakeup_display)] = !!value
    end

    private

    # Converts a method name to its corresponding Awtrix key.
    #
    # @param method_name [Symbol] the method name
    # @return [String] the corresponding Awtrix key
    def method_to_awtrix_key(method_name)
      ATTRIBUTES[method_name][:key]
    end
  end
end
