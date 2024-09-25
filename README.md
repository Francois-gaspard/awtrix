# AwtrixControl

AwtrixControl is a Ruby gem for managing and controlling Awtrix 3 devices. It provides an API to interact with devices and manage [custom apps](https://github.com/Blueforcer/awtrix3/blob/main/docs/api.md#custom-apps-and-notifications).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'awtrix_control'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install awtrix_control
```

## Usage

### Initializing Devices

To start using the gem, you need to initialize a device with the host address:

```ruby
require 'awtrix_control'

client = AwtrixControl::Device.new('192.168.1.100')
```

### Managing Apps

#### Creating a New App

You can create a new app by giving it a name, and adding it to the Device instance:

```ruby
app = device.new_app(:my_app)
```

Or:

```ruby
app = AwtrixControl::App.new(:my_app, device:)
```

Or:

```ruby
app = AwtrixControl::App.new(:my_app)
app.device = device
```

That will initialize an App instance with default values, logically associated to your device. 
Note that you need to `push` the app before it appears on your physical device. 

#### Configuring the app

See the AwtrixControl::App class for a list of methods you can call to configure your custom apps. 
E.g.:
```ruby
app.text = 'Hello World'
app.background_color = :green
```

#### Pushing an App to the Device

Once your app is configured, you can push it to its associated physical device:

```ruby
app.push
```

You can also push it by name:

```ruby
device.push_app(:my_app)
```

An exception will be raised if the app is not registered on the device:
`App my_app not found on client 192.168.31.56 (ArgumentError)`

#### Deleting an App

To delete an app from its associated device (both logical and physical):

```ruby
app.delete
```

Or by name:
```ruby
device.delete_app(:my_app)
```

An exception will be raised if the app is not registered on the device:
`App my_app not found on client 192.168.31.56 (ArgumentError)`

### Controlling the Device

#### Setting an Indicator

You can set an indicator on the device:

```ruby
device.indicator(:top, :red, effect: :blink)
```

Supported indicator locations are: `:top, :center, :bottom` (See AwtrixControl::Device)
Supported effects are: `:blink, :pulse`. They have a default sensible frequency, which can be overridden:

```ruby
device.indicator(:center, :green, effect: :pulse, frequency: 5000)
```

#### Removing an Indicator

To remove an indicator:

```ruby
client.remove_indicator(:top)
```

#### Playing a Sound

To play a sound on the device:

```ruby
client.sound('test_sound')
```
See the Awtrix3 documentation for setting up your sound files on the device:
https://github.com/Blueforcer/awtrix3/blob/main/docs/api.md?ref=domopi.eu#json-properties

#### Sending a Notification

To send a notification to the device:

```ruby
client.notify('Hello, World!', color: :blue)
```

Supported colors (see AwtrixControl module):
```
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
```
You can pass additional arguments, but note that besides colors, in this crude, early version, they are sent to the device as-is. 
I.e. you will need to follow the [Awtrix 3 documentation](https://github.com/Blueforcer/awtrix3/blob/main/docs/api.md?ref=domopi.eu#json-properties)

E.g.: 
```ruby
device.notify('Hello, World!', color: :red, noScroll: true)`
```

A future version of the gem may include a Notification class.

### Getting Device Information

#### Getting Device Stats

To get the device stats:

```ruby
stats = device.stats
puts stats
```

#### Getting Screen Data

To get the screen data:

```ruby
screen_data = device.screen
puts screen_data
```

## Example

After checking out the repo, run your ruby console and:

```ruby
>> require 'awtrix_control'
=> true

>> device = AwtrixControl::Device.new('192.168.31.56')
=> #<AwtrixControl::Device:0x000000011ef186e0 @apps={}, @host="192.168.31.56">

>> device.notify('Hello, World!', color: :red)
=> "OK"
# You should see a red `Hello World!` notification.

>> app = device.new_app(:hello_world)
=> 
#<AwtrixControl::App:0x000000011ea3c6f8...

>> app.text = 'Hello World!'
=> "Hello World!"

>> app.rainbow_effect = true
=> true

>> app.push
=> "OK

# You should see a rainbow-colored `Hello World` app on your device.

>> app.delete
=> 
#<AwtrixControl::App:0x000000011eff1a58...

# Your app should be removed from the device now.
# You can check which apps are currently registered:

>> device.apps
=> {}
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Francois-gaspard/awtrix_control

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
