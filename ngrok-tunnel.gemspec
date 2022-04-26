# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ngrok/tunnel/version'

Gem::Specification.new do |spec|
  spec.name          = "ngrok-tunnel"
  spec.version       = Ngrok::Tunnel::VERSION
  spec.authors       = ["Anton Bogdanovich"]
  spec.email         = ["27bogdanovich@gmail.com"]
  spec.summary       = %q{Ngrok-tunnel gem is a ruby wrapper for ngrok}
  spec.description   = %q{Ngrok-tunnel gem is a ruby wrapper for ngrok}
  spec.homepage      = "https://github.com/bogdanovich/ngrok-tunnel"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency("pry")
  spec.add_development_dependency("pry-byebug")
  spec.add_development_dependency("rspec", "~> 3.1")
end
