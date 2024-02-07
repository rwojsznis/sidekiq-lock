# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq/lock/version'

Gem::Specification.new do |spec|
  spec.name          = "sidekiq-lock"
  spec.version       = Sidekiq::Lock::VERSION
  spec.authors       = ["Rafal Wojsznis"]
  spec.email         = ["rafal.wojsznis@gmail.com"]
  spec.description   = spec.summary = "Simple redis-based lock mechanism for your sidekiq workers"
  spec.homepage      = "https://github.com/emq/sidekiq-lock"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + ["LICENSE.txt", "Rakefile", "README.md", "CHANGELOG.md"]
  spec.test_files    = Dir["test/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "sidekiq", ">= 6"
end
