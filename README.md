# Ngrok::Tunnel

ngrok-tunnel provides ruby wrapper for ngrok

## Installation

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

# spawn ngrok
Ngrok::Tunnel.start(3001)

# ngrok local_port
Ngrok::Tunnel.local_port

# ngrok external url
Ngrok::Tunnel.ngrok_url
Ngrok::Tunnel.ngrok_url_https

Ngrok::Tunnel.running?
Ngrok::Tunnel.stopped?

# ngrok process id
Ngrok::Tunnel.pid

# ngrok log file descriptor
Ngrok::Tunnel.log_file

# kill ngrok
Ngrok::Tunnel.stop

```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ngrok-tunnel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
