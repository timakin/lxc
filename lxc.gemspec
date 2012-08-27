# -*- encoding: utf-8 -*-
require File.expand_path('../lib/lxc/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Zachary Patten"]
  gem.email         = ["zachary@jovelabs.com"]
  gem.description   = %q{Gem for controlling local or remote Linux Containers (LXC)}
  gem.summary       = %q{Gem for controlling local or remote Linux Containers (LXC)}
  gem.homepage      = "https://github.com/zpatten/lxc"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "lxc"
  gem.require_paths = ["lib"]
  gem.version       = Lxc::VERSION
end
