# frozen_string_literal: true

require_relative 'request'

module AwtrixControl
  class App
    include AwtrixControl
    include AwtrixControl::Request
    attr_accessor :client, :name, :payload

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

    # @param name [String] the name of the app. Must be unique within the client, or the app will be overwritten
    def initialize(name, payload: nil, client: nil)
      @name = name
      @client = client
      @payload = payload || default_payload
    end

    def push
      return if @client.nil?
      @client.push_app(self)
    end

    # Define getters:
    ATTRIBUTES.each do |method_name, options|
      awtrix_attribute = options[:key]
      define_method(method_name) do
        payload[awtrix_attribute]
      end
    end

    # @param value [Boolean] whether to autoscale the bar or line chart.
    def autoscale=(value)
      @payload[method_to_awtrix_key(:auto_scale)] = !!value
    end

    # @param value [String, Symbol, Array<Integer>] the color to set the background do
    # String: A hex color code
    # Symbol: A color name. Must be a key in COLOR_MAPPINGS
    # Array: An array of 3 integers representing the RGB values of the color
    def background_color=(value)
      @payload[method_to_awtrix_key(:background_color)] = normalize_color(value)
    end

    # @param value [String] the effect to apply to the background.
    # See https://blueforcer.github.io/awtrix3/#/effects
    def background_effect=(value)
      @payload[method_to_awtrix_key(:background_effect)] = value
    end

    # @param value [Hash] the settings for the background effect.
    # See https://blueforcer.github.io/awtrix3/#/effects?id=effect-settings
    def background_effect_settings=(value)
      @payload[method_to_awtrix_key(:background_effect_settings)] = value
    end

    # @param value [Array<Integer>] An array of integers to represent each bar.
    # If an icon is shown, up to 11 values.
    # Without icon, up to 16 values.
    def bar_chart=(value)
      @payload[method_to_awtrix_key(:bar_chart)] = value
    end

    # @param value [Integer] the frequency (in ms) at which the text should blink.
    # Not compatible with gradient or rainbow.
    def blink_text=(value)
      @payload[method_to_awtrix_key(:blink_text)] = value.to_i
    end

    def blink_text
      @payload[method_to_awtrix_key(:blink_text)].to_i
    end

    # @param value [Boolean] Centers a short, non-scrollable text.
    def center_text=(value)
      @payload[method_to_awtrix_key(:center_text)] = value
    end

    def default_payload
      @default_payload ||=
        ATTRIBUTES.each_with_object({}) do |(method_name, options), hash|
        hash[options[:key]] = options[:default] if options.key?(:default)
      end
    end

    def delete
      @client.delete_app(self)
    end

    # @param value [Boolean] whether to disable text scrolling
    def disable_scroll=(value)
      @payload[method_to_awtrix_key(:disable_scroll)] = !!value
    end

    # @param value [Integer] for how long (in seconds) the notification should be shown
    def display_duration=(value)
      @payload[method_to_awtrix_key(:display_duration)] = value.to_i
    end

    # @param value [Array] Array of drawing instructions. Each object represents a drawing command.
    # See https://github.com/Blueforcer/awtrix3/blob/main/docs/api.md#drawing-instructions
    def draw_commands=(value)
      @payload[method_to_awtrix_key(:draw_commands)] = value
    end

    # @param value [Integer] the frequency (in ms) at which the text should fade in and out
    # Not compatible with gradient or rainbow.
    def fade_text=(value)
      @payload[method_to_awtrix_key(:fade_text)] = value.to_i
    end

    def fade_text
      @payload[method_to_awtrix_key(:fade_text)].to_i
    end

    # @param value [Array<String>] An array of IP addresses of other devices to forward notifications to
    def forward_clients=(value)
      @payload[method_to_awtrix_key(:forward_clients)] = value
    end

    def hold_notification=(value)
      @payload[method_to_awtrix_key(:hold_notification)] = !!value
    end

    # @param value [String] The Icon ID or filename (without extension) to display on the app.
    # You can also pass a 8x8 jpg as a Base64 String.
    def icon=(value)
      @payload[method_to_awtrix_key(:icon)] = value
    end

    # @param value [Integer] Remove the app when no update is received for the given time in seconds.
    def lifetime=(value)
      @payload[method_to_awtrix_key(:lifetime)] = value.to_i
    end

    # @param value [Symbol, Integer] the lifetime mode to use
    # Symbol options: :destroy, :stale
    # Integer options: 0, 1
    def lifetime_mode=(value)
      @payload[method_to_awtrix_key(:lifetime_mode)] = LIFETIME_MODE_OPTIONS[value] || value
    end

    def lifetime_mode
      LIFETIME_MODE_OPTIONS.key(@payload[method_to_awtrix_key(:lifetime_mode)])
    end

    # @param value [Array<Integer>] An array of integers to represent the line chart
    # The array should contain up to 16 values, or 11 if an icon is shown.
    def line_chart=(value)
      @payload[method_to_awtrix_key(:line_chart)] = value
    end

    # @param value [Boolean] whether to loop the sound as long as the notification is shown
    def loop_sound=(value)
      @payload[method_to_awtrix_key(:loop_sound)] = !!value
    end

    # @param value [String] Sets an effect overlay (cannot be used with global overlays).
    def overlay_effect=(value)
      @payload[method_to_awtrix_key(:overlay_effect)] = value
    end

    # @param value [Integer] Set the position of the app in the loop (starting at 0). Experimental.
    def position=(value)
      @payload[method_to_awtrix_key(:position)] = value
    end

    # @param value [Integer] A value between 0 and 100 to set the progress bar to.
    def progress_bar=(value)
      @payload[method_to_awtrix_key(:progress_bar)] = value.to_i
    end

    def progress_bar_background_color=(value)
      @payload[method_to_awtrix_key(:progress_bar_background_color)] = normalize_color(value)
    end

    # @param value [String, Symbol, Array<Integer>] the color to set the progress bar to
    def progress_bar_color=(value)
      @payload[method_to_awtrix_key(:progress_bar_color)] = normalize_color(value)
    end

    # @param value [Symbol, Integer] a symbol defining the push icon behavior:
    # :fixed, :scroll_once, :loop
    # Or an integer between 0 and 2 representing the above symbols.
    def push_icon=(value)
      @payload[method_to_awtrix_key(:push_icon)] = PUSH_ICON_OPTIONS[value] || value
    end

    def push_icon
      PUSH_ICON_OPTIONS.key(@payload[method_to_awtrix_key(:push_icon)])
    end

    # @param value [Boolean] whether to enable the rainbow effect
    def rainbow_effect=(value)
      @payload[method_to_awtrix_key(:rainbow_effect)] = !!value
    end

    # @param value [Integer] the number of times to repeat the text
    def repeat_text=(value)
      @payload[method_to_awtrix_key(:repeat_text)] = value.to_i
    end

    # @param value [String] A RTTTL string to play as a sound.
    def rtttl_sound=(value)
      @payload[method_to_awtrix_key(:rtttl_sound)] = value
    end

    # @param value [Boolean] Saves your custom app into flash and reloads it after boot. Avoid this for custom apps
    # with high update frequencies because the ESP's flash memory has limited write cycles.
    def save_app=(value)
      @payload[method_to_awtrix_key(:save_app)] = !!value
    end

    # @param value [Integer] the new scroll speed, as a percentage of the original scroll speed.
    def scroll_speed=(value)
      @payload[method_to_awtrix_key(:scroll_speed)] = value.to_i
    end

    # @param value [Boolean] whether to stack the notification.
    # I.e. when false, replaces the notification immediately.
    # When true, lets the current notification finish before showing the new one.
    def stack_notifications=(value)
      @payload[method_to_awtrix_key(:stack_notifications)] = !!value
    end

    # @param value [String] The filename of your RTTTL ringtone file placed in the MELODIES folder (without extension).
    # Or the 4 digit number of your MP3 if youre using a DFplayer
    def sound=(value)
      @payload[method_to_awtrix_key(:sound)] = value
    end

    # @param value [String] the text to display
    def text=(value)
      @payload[method_to_awtrix_key(:text)] = value
    end

    # @param value [Symbol, Integer] the text case to use
    # Symbol options: :default, :upcase, :as_is
    # Integer options: 0, 1, 2
    def text_case=(value)
      @payload[method_to_awtrix_key(:text_case)] = TEXT_CASES[value] || value
    end

    def text_case
      TEXT_CASES.key(@payload[method_to_awtrix_key(:text_case)])
    end

    # @param value [String, Symbol, Array<Integer>] the color to set the text to
    # String: A hex color code
    # Symbol: A color name. Must be a key in COLOR_MAPPINGS
    # Array: An array of 3 integers representing the RGB values of the color
    def text_color=(value)
      @payload[method_to_awtrix_key(:text_color)] = normalize_color(value)
    end

    # @param gradient [Hash] a hash with keys :from and :to, each with a color value in String, Symbol or array format.
    # String: A hex color code
    # Symbol: A color name. Must be a key in COLOR_MAPPINGS
    # Array: An array of 3 integers representing the RGB values of the color
    def text_gradient=(gradient)
      from = normalize_color(gradient[:from])
      to = normalize_color(gradient[:to])
      @payload[method_to_awtrix_key(:text_gradient)] = [from, to]
    end

    def text_gradient
      raw_gradient = @payload[method_to_awtrix_key(:text_gradient)]
      return { from: nil, to: nil } if raw_gradient.nil?
      {
        from: raw_gradient[0],
        to: raw_gradient[1]
      }
    end

    # @param value [Integer] Sets an offset for the x position of a starting text.
    def text_offset=(value)
      @payload[method_to_awtrix_key(:text_offset)] = value
    end

    # @param value [Boolean] Draw the text on top.
    def top_text=(value)
      @payload[method_to_awtrix_key(:top_text)] = value
    end

    def upcase
      @payload[method_to_awtrix_key(:text_case)] = 1
    end

    # @param value [Boolean] whether to wake up the matrix for the notification when it's off
    def wakeup_display=(value)
      @payload[method_to_awtrix_key(:wakeup_display)] = !!value
    end

    private

    def method_to_awtrix_key(method_name)
      ATTRIBUTES[method_name][:key]
    end
  end
end
