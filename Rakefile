#!/usr/bin/env rake
# frozen_string_literal: true

require "bundler/gem_tasks"
require "fileutils"
require "rake/testtask"
require_relative "lib/sidekiq/lock/version"

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

namespace :release do
  desc "Validate the changelog entry for the current version"
  task :check do
    version = Sidekiq::Lock::VERSION
    changelog = File.read("CHANGELOG.md")
    heading = /^## #{Regexp.escape(version)} \([^)]+\)$/
    entry = changelog.match(/#{heading.source}\n+(.*?)(?=^## |\z)/m)

    abort "CHANGELOG.md has no entry for version #{version}" unless entry
    abort "CHANGELOG.md entry for version #{version} is empty" if entry[1].strip.empty?
  end

  desc "Write GitHub release notes from the current changelog entry"
  task notes: :check do
    version = Sidekiq::Lock::VERSION
    changelog = File.read("CHANGELOG.md")
    entry = changelog.match(/^## #{Regexp.escape(version)} \([^)]+\)\n+(.*?)(?=^## |\z)/m)

    FileUtils.mkdir_p("pkg")
    File.write("pkg/release-notes.md", "#{entry[1].strip}\n")
  end
end
