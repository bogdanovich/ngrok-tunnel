# Ngrok::Tunnel

Ngrok-tunnel gem is a ruby wrapper for ngrok v2.

[![Gem Version](https://badge.fury.io/rb/ngrok-tunnel.svg)](http://badge.fury.io/rb/ngrok-tunnel)  [![Code Climate](https://codeclimate.com/github/bogdanovich/ngrok-tunnel/badges/gpa.svg)](https://codeclimate.com/github/bogdanovich/ngrok-tunnel)

## Installation

*Note:* You must have ngrok v2+ installed available in your `PATH`.

Add this line to your application's Gemfile:

```ruby
gem 'ngrok-tunnel'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ngrok-tunnel

## Usage

```ruby
require 'ngrok/tunnel'

# spawn ngrok (default port 3001)
Ngrok::Tunnel.start

# ngrok local_port
Ngrok::Tunnel.port
=> 3001

# ngrok external url
Ngrok::Tunnel.ngrok_url
=> "http://aaa0e65.ngrok.io"

Ngrok::Tunnel.ngrok_url_https
=> "https://aaa0e65.ngrok.io"

Ngrok::Tunnel.running?
=> true

Ngrok::Tunnel.stopped?
=> false

# ngrok process id
Ngrok::Tunnel.pid
=> 27384

# ngrok log file descriptor
Ngrok::Tunnel.log
=> #<File:/tmp/ngrok20141022-27376-cmmiq4>

# kill ngrok
Ngrok::Tunnel.stop
=> :stopped

```

```ruby
# ngrok custom parameters
Ngrok::Tunnel.start(addr: 'foo.dev:80',
                    subdomain: 'MY_SUBDOMAIN',
                    hostname: 'MY_HOSTNAME',
                    authtoken: 'MY_TOKEN',
                    inspect: false,
                    log: 'ngrok.log',
                    config: '~/.ngrok',
                    persistence: true,
                    persistence_file: '/tmp/ngrok-process') # optional parameter

```

### With Rails (Rack server)

See [examples/rack-server.rb](examples/rack-server.rb) to get an idea how to use it along with a Rack server so that it automatically starts and stops when a Rack server does.

### With RSpec and Capybara

Use this gem: [ngrok-rspec](https://github.com/bogdanovich/ngrok-rspec)

## Contributing

1. Fork it ( https://github.com/bogdanovich/ngrok-tunnel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
