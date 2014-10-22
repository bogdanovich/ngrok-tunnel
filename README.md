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

# spawn ngrok at local port 3001
Ngrok::Tunnel.start(3001)

# ngrok local_port
Ngrok::Tunnel.local_port
=> 3001


# ngrok external url
Ngrok::Tunnel.ngrok_url
=> "http://aaa0e65.ngrok.com"

Ngrok::Tunnel.ngrok_url_https
=> "https://aaa0e65.ngrok.com"

Ngrok::Tunnel.running?
=> true

Ngrok::Tunnel.stopped?
=> false

# ngrok process id
Ngrok::Tunnel.pid
=> 27384

# ngrok log file descriptor
Ngrok::Tunnel.log_file
=> #<File:/tmp/ngrok20141022-27376-cmmiq4>

# kill ngrok
Ngrok::Tunnel.stop
=> :stopped

```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ngrok-tunnel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
