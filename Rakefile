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

# `steep check` requires RBS signatures for dry-struct / dry-validation,
# which are not bundled with those gems; it is therefore opt-in rather than
# part of the default task. `rbs:validate` covers signature soundness.
task default: %i[test rubocop]
