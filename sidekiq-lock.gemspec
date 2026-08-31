# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq/lock/version'

Gem::Specification.new do |spec|
  spec.name          = "sidekiq-lock"
  spec.version       = Sidekiq::Lock::VERSION
  spec.authors       = ["Rafal Wojsznis"]
  spec.email         = ["rafal.wojsznis@gmail.com"]
  spec.description   = spec.summary = "Simple redis-based lock mechanism for your sidekiq workers"
  spec.homepage      = "https://github.com/rwojsznis/sidekiq-lock"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/rwojsznis/sidekiq-lock/issues",
    "changelog_uri" => "https://github.com/rwojsznis/sidekiq-lock/blob/main/CHANGELOG.md",
    "source_code_uri" => "https://github.com/rwojsznis/sidekiq-lock",
    "rubygems_mfa_required" => "true"
  }

  spec.files         = Dir["lib/**/*"] + ["LICENSE.txt", "Rakefile", "README.md", "CHANGELOG.md"]
  spec.test_files    = Dir["test/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "sidekiq", ">= 6"
end
