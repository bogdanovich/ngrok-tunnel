# Add these to the end of a configuration file of your prefered web-server,
# e.g. config/puma.rb, config/unicorn.rb, or config/thin.rb
# Use ./.ngrok or ~/.ngrok as a config file. Don't forget to add it to `.gitignore' in the former case.
# Set NGROK_INSPECT=false to disable the inspector web-server.
unless ENV['RAILS_ENV'] == 'production'
  require 'ngrok/tunnel'
  options = {addr: ENV['PORT']}
  if File.file? '.ngrok'
    options[:config] = '.ngrok'
  elsif File.file? ENV['HOME'] + '/.ngrok'
    options[:config] = ENV['HOME'] + '/.ngrok'
  end
  if ENV['NGROK_INSPECT']
    options[:inspect] = ENV['NGROK_INSPECT']
  end
  puts "[NGROK] tunneling at " + Ngrok::Tunnel.start(options)
  unless ENV['NGROK_INSPECT'] == 'false'
    puts "[NGROK] inspector web interface listening at http://127.0.0.1:4040"
  end
end
