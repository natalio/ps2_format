# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'PS2Format/version'

Gem::Specification.new do |spec|
  spec.name          = "PS2Format"
  spec.version       = PS2Format::VERSION
  spec.authors       = ["Runtime Revolution"]

  spec.summary       = %q{PS2 provides you the ability of creating PS2 type files used to make financial transfers with a bank.}
  spec.description   = %q{PS2 provides you the ability of creating PS2 type files used to make financial transfers with a bank.}
  spec.license       = "MIT"
  spec.homepage      = "https://github.com/runtimerevolution/ps2"
  spec.email         = 'info@runtime-revolution.com'

  spec.files         = Dir["{lib}/**/*"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "i18n", "~> 0.7.0"
  spec.add_dependency "citizenship", "~> 1.0"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit", "~> 3.1.2"
end
