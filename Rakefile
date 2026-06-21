# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new

namespace :rbs do
  desc "Validate the RBS signature files (syntax + consistency)"
  task :validate do
    sh "bundle exec rbs validate"
  end
end

# ── Version bumping ───────────────────────────────────────────────────────────

namespace :version do
  VERSION_FILE = "lib/smartbill/sdk/version.rb"

  def current_version
    unless File.exist?(VERSION_FILE) && (m = File.read(VERSION_FILE).match(/VERSION\s*=\s*"([^"]+)"/))
      raise "Could not parse VERSION from #{VERSION_FILE}"
    end

    m[1]
  end

  def bump_file(current, new_version)
    content = File.read(VERSION_FILE)
    updated = content.sub(/VERSION\s*=\s*"#{Regexp.escape(current)}"/, %(VERSION = "#{new_version}"))
    File.write(VERSION_FILE, updated)
    puts "→ #{VERSION_FILE} bump to #{new_version}"
  end

  def commit_and_tag(new_version)
    sh "git add #{VERSION_FILE}"
    sh "git commit -m 'Bump version to #{new_version}'"
    sh "git tag v#{new_version}"
  end

  desc "Show current version"
  task :current do
    puts current_version
  end

  desc "Bump the PATCH version (1.0.0 → 1.0.1) and commit+tag"
  task :patch do
    current = current_version
    parts    = current.split(".").map(&:to_i)
    parts[2] += 1
    new_v   = parts.join(".")

    bump_file(current, new_v)
    commit_and_tag(new_v)
  end

  desc "Bump the MINOR version (1.0.0 → 1.1.0) and commit+tag"
  task :minor do
    current = current_version
    parts    = current.split(".").map(&:to_i)
    parts[1] += 1
    parts[2] = 0
    new_v   = parts.join(".")

    bump_file(current, new_v)
    commit_and_tag(new_v)
  end

  desc "Bump the MAJOR version (1.0.0 → 2.0.0) and commit+tag"
  task :major do
    current = current_version
    parts    = current.split(".").map(&:to_i)
    parts[0] += 1
    parts[1] = 0
    parts[2] = 0
    new_v   = parts.join(".")

    bump_file(current, new_v)
    commit_and_tag(new_v)
  end
end

# ── Deploy / Release ──────────────────────────────────────────────────────────

namespace :release do
  desc "Run the full CI suite before releasing (test + rubocop + rbs:validate + build)"
  task check: %i[test rubocop rbs:validate build]

  desc "Push the built gem to RubyGems.org (requires 'gem signin' first)"
  task :push do
    pkg = Dir.glob("pkg/*.gem").max_by { |f| File.mtime(f) }
    unless pkg
      raise "No .gem found in pkg/. Run `rake build` first."
    end

    sh "gem push #{pkg}"
    puts "✓ #{File.basename(pkg)} pushed to RubyGems.org"
  end

  desc "Deploy: check → build → push gem to RubyGems.org (no git tagging — use 'rake release' for full release)"
  task gem_only: %i[check push]
end

# `steep check` requires RBS signatures for dry-struct / dry-validation,
# which are not bundled with those gems; it is therefore opt-in rather than
# part of the default task. `rbs:validate` covers signature soundness.
task default: %i[test rubocop]
