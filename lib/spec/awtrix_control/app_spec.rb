# frozen_string_literal: true

require 'spec_helper'

describe AwtrixControl::App do
  before do
    @device = AwtrixControl::Device.new(DEFAULT_HOST)
    @app = AwtrixControl::App.new(:test_app)
  end

  # describe '.awtrix_key_to_method_name' do
  #   it 'converts an awtrix key to a method name' do
  #     expect(AwtrixControl::App.awtrix_key_to_method_name('text')).to eq('text')
  #     expect(AwtrixControl::App.awtrix_key_to_method_name('push_icon')).to eq('pushIcon')
  #   end
  # end

  describe '#initialize' do
    it 'initializes instance variables' do
      expect(@app.name).to eq(:test_app)
      expect(@app.payload)
        .to eq(
              {
                "autoScale" => true,
                "center" => true,
                "duration" => 5,
                "hold" => false,
                "lifetime" => 0,
                "lifetimeMode" => 0,
                "loopSound" => false,
                "noScroll" => false,
                "progress" => -1,
                "progressBC" => -1,
                "progressC" => -1,
                "pushIcon" => 0,
                "repeat" => -1,
                "scrollSpeed" => 100,
                "stack" => true,
                "textCase" => 0,
                "textOffset" => 0,
                "topText" => false,
                "wakeup" => false,
              }

            )
    end

    it 'registers the app on the device if device is present' do
      app = AwtrixControl::App.new(:test_app, device: @device)
      expect(@device.apps[:test_app]).to eq(app)
    end
  end

  describe '#autoscale=' do
    it 'sets the autoscale value' do
      @app.autoscale = true
      expect(@app.payload['autoScale']).to be true

      @app.autoscale = false
      expect(@app.payload['autoScale']).to be false
    end
  end

  describe '#background_effect=' do
    it 'sets the background effect' do
      @app.background_effect = 'BrickBreaker'
      expect(@app.payload['effect']).to eq('BrickBreaker')
    end
  end

  describe '#background_effect' do
    it 'gets the background effect' do
      @app.payload = { 'effect' => 'BrickBreaker' }
      expect(@app.background_effect).to eq('BrickBreaker')
    end
  end

  describe '#background_effect_settings=' do
    it 'sets the background effect settings' do
      @app.background_effect_settings = { 'speed' => 5 }
      expect(@app.payload['effectSettings']).to eq({ 'speed' => 5 })
    end
  end

  describe '#background_effect_settings' do
    it 'gets the background effect settings' do
      @app.payload = { 'effectSettings' => { 'speed' => 5 } }
      expect(@app.background_effect_settings).to eq({ 'speed' => 5 })
    end
  end

  describe '#bar_chart=' do
    it 'sets the bar chart' do
      @app.bar_chart = [1, 2, 3]
      expect(@app.payload['bar']).to eq([1, 2, 3])
    end
  end

  describe '#bar_chart' do
    it 'gets the bar chart' do
      @app.payload = { 'bar' => [1, 2, 3] }
      expect(@app.bar_chart).to eq([1, 2, 3])
    end
  end

  describe '#center_text=' do
    it 'sets whether to center the text' do
      @app.center_text = true
      expect(@app.payload['center']).to be true

      @app.center_text = false
      expect(@app.payload['center']).to be false
    end
  end

  describe '#center_text' do
    it 'gets whether to center the text' do
      @app.payload = { 'center' => true }
      expect(@app.center_text).to eq(true)
    end
  end

  describe '#device=' do
    it 'sets the device' do
      @app.device = @device
      expect(@app.device).to eq(@device)
      expect(@device.apps[:test_app]).to eq(@app)
    end

    it 'unregisters the app from a device before adding it to another device' do
      device2 = AwtrixControl::Device.new(DEFAULT_HOST)
      @app.device = @device
      expect(@device.apps[:test_app]).to eq(@app)
      @app.device = device2
      expect(@device.apps[:test_app]).to be_nil
      expect(device2.apps[:test_app]).to eq(@app)
    end


  end

  describe '#disable_scroll=' do
    it 'sets whether to disable scrolling' do
      @app.disable_scroll = true
      expect(@app.payload['noScroll']).to be true

      @app.disable_scroll = false
      expect(@app.payload['noScroll']).to be false
    end
  end

  describe '#disable_scroll' do
    it 'gets whether to disable scrolling' do
      @app.payload = { 'noScroll' => false }
      expect(@app.disable_scroll).to eq(false)
    end
  end

  describe '#display_duration=' do
    it 'sets the display duration' do
      @app.display_duration = 5
      expect(@app.payload['duration']).to eq(5)
    end
  end

  describe '#display_duration' do
    it 'gets the display duration' do
      @app.payload = { 'duration' => 5 }
      expect(@app.display_duration).to eq(5)
    end
  end

  describe '#draw_commands=' do
    it 'sets the draw commands' do
      @app.draw_commands = [1, 2, 3]
      expect(@app.payload['draw']).to eq([1, 2, 3])
    end
  end

  describe '#draw_commands' do
    it 'gets the draw commands' do
      @app.payload = { 'draw' => [1, 2, 3] }
      expect(@app.draw_commands).to eq([1, 2, 3])
    end
  end

  describe '#forward_clients=' do
    it 'sets the forward clients' do
      @app.forward_clients = ['192.168.0.1']
      expect(@app.payload['clients']).to eq(['192.168.0.1'])
    end
  end

  describe '#forward_clients' do
    it 'gets the forward clients' do
      @app.payload = { 'clients' => ['192.168.0.1'] }
      expect(@app.forward_clients).to eq(['192.168.0.1'])
    end
  end

  describe '#hold_notification=' do
    it 'sets the hold notification' do
      @app.hold_notification = false
      expect(@app.payload['hold']).to be false
    end
  end

  describe '#hold_notification' do
    it 'gets the hold notification' do
      @app.payload = { 'hold' => false }
      expect(@app.hold_notification).to eq(false)
    end
  end

  describe '#lifetime=' do
    it 'sets the lifetime' do
      @app.lifetime = 5
      expect(@app.payload['lifetime']).to eq(5)
    end
  end

  describe '#lifetime' do
    it 'gets the lifetime' do
      @app.payload = { 'lifetime' => 5 }
      expect(@app.lifetime).to eq(5)
    end
  end

  describe '#lifetime_mode=' do
    it 'sets the lifetime mode' do
      @app.lifetime_mode = 0
      expect(@app.payload['lifetimeMode']).to eq(0)

      @app.lifetime_mode = :stale
      expect(@app.payload['lifetimeMode']).to eq(1)
    end
  end

  describe '#lifetime_mode' do
    it 'gets the lifetime mode' do
      @app.payload = { 'lifetimeMode' => 1 }
      expect(@app.lifetime_mode).to eq(:stale)
    end
  end

  describe '#line_chart=' do
    it 'sets the line chart' do
      @app.line_chart = [1, 2, 3]
      expect(@app.payload['line']).to eq([1, 2, 3])
    end
  end

  describe '#line_chart' do
    it 'gets the line chart' do
      @app.payload = { 'line' => [1, 2, 3] }
      expect(@app.line_chart).to eq([1, 2, 3])
    end
  end

  describe '#loop_sound=' do
    it 'sets the loop sound' do
      @app.loop_sound = true
      expect(@app.payload['loopSound']).to be true
    end
  end

  describe '#loop_sound' do
    it 'gets the loop sound' do
      @app.payload = { 'loopSound' => true }
      expect(@app.loop_sound).to eq(true)
    end
  end

  describe '#overlay_effect=' do
    it 'sets the overlay' do
      @app.overlay_effect = 'snow'
      expect(@app.payload['overlay']).to eq('snow')
    end
  end

  describe '#overlay' do
    it 'gets the overlay' do
      @app.payload = { 'overlay' => 'snow' }
      expect(@app.overlay_effect).to eq('snow')
    end
  end

  describe '#position=' do
    it 'sets the position' do
      @app.position = 5
      expect(@app.payload['pos']).to eq(5)
    end
  end

  describe '#position' do
    it 'gets the position' do
      @app.payload = { 'pos' => 5 }
      expect(@app.position).to eq(5)
    end
  end

  describe '#progress_bar=' do
    it 'sets the progress bar' do
      @app.progress_bar = 50
      expect(@app.payload['progress']).to eq(50)
    end
  end

  describe '#progress_bar' do
    it 'gets the progress bar' do
      @app.payload = { 'progress' => 50 }
      expect(@app.progress_bar).to eq(50)
    end
  end

  describe '#progress_bar_color=' do
    it 'sets the progress bar color' do
      @app.progress_bar_color = :red
      expect(@app.payload['progressC']).to eq('#ff0000')
    end
  end

  describe '#progress_bar_color' do
    it 'gets the progress bar color' do
      @app.payload = { 'progressC' => '#ff0000' }
      expect(@app.progress_bar_color).to eq('#ff0000')
    end
  end

  describe '#progress_bar_background_color=' do
    it 'sets the progress bar background color' do
      @app.progress_bar_background_color = :red
      expect(@app.payload['progressBC']).to eq('#ff0000')
    end
  end

  describe '#progress_bar_background_color' do
    it 'gets the progress bar background color' do
      @app.payload = { 'progressBC' => '#ff0000' }
      expect(@app.progress_bar_background_color).to eq('#ff0000')
    end
  end

  describe '#push_icon=' do
    it 'sets the push icon' do
      @app.push_icon = :scroll_once
      expect(@app.payload['pushIcon']).to eq(1)

      @app.push_icon = :loop
      expect(@app.payload['pushIcon']).to eq(2)

      @app.push_icon = :fixed
      expect(@app.payload['pushIcon']).to eq(0)

      @app.push_icon = 2
      expect(@app.payload['pushIcon']).to eq(2)
    end
  end

  describe '#push_icon' do
    it 'gets the push icon' do
      @app.payload = { 'pushIcon' => 2 }
      expect(@app.push_icon).to eq(:loop)
    end
  end

  describe '#repeat_text=' do
    it 'sets the text repetition count' do
      @app.repeat_text = 5
      expect(@app.payload['repeat']).to eq(5)
    end
  end

  describe '#repeat_text' do
    it 'gets the text repetition count' do
      @app.payload = { 'repeat' => 5 }
      expect(@app.repeat_text).to eq(5)
    end
  end

  describe '#rtttl_sound=' do
    it 'sets the RTTTL sound' do
      @app.rtttl_sound = 'rtttl_string'
      expect(@app.payload['rtttl']).to eq('rtttl_string')
    end
  end

  describe '#rtttl_sound' do
    it 'gets the RTTTL sound' do
      @app.payload = { 'rtttl' => 'rtttl_string' }
      expect(@app.rtttl_sound).to eq('rtttl_string')
    end
  end

  describe '#save_app=' do
    it 'sets the save app' do
      @app.save_app = true
      expect(@app.payload['save']).to be true
    end
  end

  describe '#save_app' do
    it 'gets the save app' do
      @app.payload = { 'save' => true }
      expect(@app.save_app).to eq(true)
    end
  end

  describe '#scroll_speed=' do
    it 'sets the scroll speed' do
      @app.scroll_speed = 5
      expect(@app.payload['scrollSpeed']).to eq(5)
    end
  end

  describe '#scroll_speed' do
    it 'gets the scroll speed' do
      @app.payload = { 'scrollSpeed' => 5 }
      expect(@app.scroll_speed).to eq(5)
    end
  end

  describe '#sound=' do
    it 'sets the sound' do
      @app.sound = 'sound_name'
      expect(@app.payload['sound']).to eq('sound_name')
    end
  end

  describe '#sound' do
    it 'gets the sound' do
      @app.payload = { 'sound' => 'sound_name' }
      expect(@app.sound).to eq('sound_name')
    end
  end

  describe '#stack_notifications=' do
    it 'sets the stack notifications' do
      @app.stack_notifications = true
      expect(@app.payload['stack']).to be true
    end
  end

  describe '#stack_notifications' do
    it 'gets the stack notifications' do
      @app.payload = { 'stack' => true }
      expect(@app.stack_notifications).to eq(true)
    end
  end

  describe '#text=' do
    it 'sets the text payload' do
      @app.text = 'Hello, World!'
      expect(@app.payload['text']).to eq('Hello, World!')
    end
  end

  describe '#text' do
    it 'gets the text payload' do
      @app.payload = { 'text' => 'Hello, World!' }
      expect(@app.text).to eq('Hello, World!')
    end
  end

  describe '#text_case=' do
    it 'sets the text case via helper values' do
      @app.text_case = :default
      expect(@app.payload['textCase']).to eq(0)

      @app.text_case = :upcase
      expect(@app.payload['textCase']).to eq(1)

      @app.text_case = :as_is
      expect(@app.payload['textCase']).to eq(2)
    end

    it 'sets the text case via integer values' do
      @app.text_case = 2
      expect(@app.payload['textCase']).to eq(2)
    end
  end

  describe '#text_case' do
    it 'gets the text case payload' do
      @app.payload = { 'textCase' => 1 }
      expect(@app.text_case).to eq(:upcase)
    end
  end

  describe '#top_text=' do
    it 'sets whether to draw the text on top' do
      @app.top_text = true
      expect(@app.payload['topText']).to be true

      @app.top_text = false
      expect(@app.payload['topText']).to be false
    end
  end

  describe '#top_text' do
    it 'gets whether to draw the text on top' do
      @app.payload = { 'topText' => true }
      expect(@app.top_text).to eq(true)
    end
  end

  describe '#text_offset=' do
    it 'sets the text offset' do
      @app.text_offset = 5
      expect(@app.payload['textOffset']).to eq(5)
    end
  end

  describe '#text_offset' do
    it 'gets the text offset' do
      @app.payload = { 'textOffset' => 5 }
      expect(@app.text_offset).to eq(5)
    end
  end

  describe '#text_color=' do
    it 'sets the text color via convenience names' do
      @app.text_color = :red
      expect(@app.payload['color']).to eq('#ff0000')
    end

    it 'sets the text color via hex values' do
      @app.text_color = '#ff0000'
      expect(@app.payload['color']).to eq('#ff0000')
    end
  end

  describe '#text_color' do
    it 'gets the text color' do
      @app.payload = { 'color' => '#ff0000' }
      expect(@app.text_color).to eq('#ff0000')
    end
  end

  describe '#text_gradient=' do
    it 'sets the text gradient' do
      @app.text_gradient = { from: :red, to: :blue }
      expect(@app.payload['gradient']).to eq(%w[#ff0000 #0000ff])
    end

    it 'sets the text gradient via hex values' do
      @app.text_gradient = { from: '#ff0000', to: '#0000ff' }
      expect(@app.payload['gradient']).to eq(%w[#ff0000 #0000ff])
    end
  end

  describe '#text_gradient' do
    it 'gets the text gradient' do
      @app.payload = { 'gradient' => %w[#ff0000 #0000ff] }
      expect(@app.text_gradient).to eq({ from: '#ff0000', to: '#0000ff' })
    end

    it 'returns blank values by default' do
      expect(@app.text_gradient).to eq({ from: nil, to: nil })
    end
  end

  describe '#background_color=' do
    it 'sets the background color to the given color' do
      @app.background_color = :red
      expect(@app.payload['background']).to eq('#ff0000')

      @app.background_color = '#00ff00'
      expect(@app.payload['background']).to eq('#00ff00')
    end
  end

  describe '#background_color' do
    it 'gets the background color' do
      @app.payload = { 'background' => '#00ff00' }
      expect(@app.background_color).to eq('#00ff00')
    end
  end

  describe '#blink_text=' do
    it 'sets the text to blink at the given frequency' do
      @app.blink_text = 1000
      expect(@app.payload['blinkText']).to eq(1000)

      @app.blink_text = 500
      expect(@app.payload['blinkText']).to eq(500)
    end
  end

  describe '#blink_text' do
    it 'gets the blinking frequency' do
      @app.payload = { 'blinkText' => 500 }
      expect(@app.blink_text).to eq(500)
    end
  end

  describe '#fade_text=' do
    it 'sets the text to fade at the given frequency' do
      @app.fade_text = 1000
      expect(@app.payload['fadeText']).to eq(1000)

      @app.fade_text = 500
      expect(@app.payload['fadeText']).to eq(500)
    end
  end

  describe '#fade_text' do
    it 'gets the fading frequency' do
      @app.payload = { 'fadeText' => 500 }
      expect(@app.fade_text).to eq(500)
    end
  end

  describe '#icon=' do
    it 'sets the icon' do
      @app.icon = 'icon_name'
      expect(@app.payload['icon']).to eq('icon_name')
    end
  end

  describe '#icon' do
    it 'gets the icon' do
      @app.payload = { 'icon' => 'icon_name' }
      expect(@app.icon).to eq('icon_name')
    end
  end

  describe '#rainbow_effect=' do
    it 'sets the rainbow effect' do
      @app.rainbow_effect = true
      expect(@app.payload['rainbow']).to be true

      @app.rainbow_effect = false
      expect(@app.payload['rainbow']).to be false
    end
  end

  describe '#rainbow_effect' do
    it 'gets the rainbow effect' do
      @app.payload = { 'rainbow' => true }
      expect(@app.rainbow_effect).to eq(true)
    end
  end

  describe '#wakeup_display=' do
    it 'sets the wakeup display' do
      @app.wakeup_display = true
      expect(@app.payload['wakeup']).to be true

      @app.wakeup_display = false
      expect(@app.payload['wakeup']).to be false
    end
  end

  describe '#wakeup_display' do
    it 'gets the wakeup display' do
      @app.payload = { 'wakeup' => true }
      expect(@app.wakeup_display).to eq(true)
    end
  end
end
