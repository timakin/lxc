# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lxc/version'

Gem::Specification.new do |spec|
  spec.name          = "lxc"
  spec.version       = LXC::VERSION
  spec.authors       = ["Zachary Patten"]
  spec.email         = ["zachary@jovelabs.com"]
  spec.description   = %q(An interface for controlling local or remote Linux Containers (LXC))
  spec.summary       = %q(An interface for controlling local or remote Linux Containers (LXC))
  spec.homepage      = "https://github.com/zpatten/lxc"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency("ztk")

  spec.add_development_dependency("bundler", "~> 1.3")
  spec.add_development_dependency("pry")
  spec.add_development_dependency("rake")
  spec.add_development_dependency("redcarpet")
  spec.add_development_dependency("rspec")
  spec.add_development_dependency("simplecov")
  spec.add_development_dependency("yard")
end
