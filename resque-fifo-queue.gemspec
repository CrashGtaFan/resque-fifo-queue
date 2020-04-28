# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque/plugins/fifo/queue/version'

Gem::Specification.new do |spec|
  spec.name          = "resque-fifo-queue"
  spec.version       = Resque::Plugins::Fifo::Queue::VERSION
  spec.authors       = ["Joseph Emmanuel Dayo"]
  spec.email         = ["joseph.dayo@gmail.com"]

  spec.summary       = %q{Implements a federated fifo queue with consistent hashing on top of resque}
  spec.description   = %q{Implements a federated fifo queue with consistent hashing on top of resque}
  spec.homepage      = "https://github.com/jedld/resque-fifo-queue"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "pry-debugger"
  spec.add_dependency "redis"
  spec.add_dependency "resque", "~> 1.27"
  spec.add_dependency "resque-scheduler"
  spec.add_dependency "resque-pause"
  spec.add_dependency "xxhash"
  spec.add_dependency "redlock"
end
