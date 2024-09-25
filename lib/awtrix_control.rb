# frozen_string_literal: true

require 'awtrix_control/app'
require 'awtrix_control/client'
require 'awtrix_control/request'

module AwtrixControl
  COLOR_MAPPINGS = {
    black: '#000000',
    blue: '#0000ff',
    brown: '#804000',
    green: '#00ff00',
    orange: '#ff8000',
    pink: '#ff00ff',
    purple: '#8000ff',
    red: '#ff0000',
    white: '#ffffff',
    yellow: '#ffff00',
  }.freeze

  def normalize_color(color)
    case color
    when String
      color
    when Symbol
      COLOR_MAPPINGS[color] || color.to_s
    when Array
      format('#%02x%02x%02x', *color)
    else
      raise ArgumentError, "Invalid color format: #{color.inspect}"
    end
  end
end
