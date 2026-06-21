# frozen_string_literal: true

require_relative "lib/smartbill/sdk/version"

Gem::Specification.new do |spec|
  spec.name = "smartbill-sdk"
  spec.version = Smartbill::Sdk::VERSION
  spec.authors = ["Denis Nutiu"]
  spec.email = ["dnutiu@hey.com"]

  spec.summary = "Ruby SDK for the SmartBill Cloud REST API."
  spec.description = "A Ruby SDK for the SmartBill Cloud REST API, offering a synchronous " \
                     "client with typed request/response models for invoices, proformas, " \
                     "payments, e-mail, taxes, series and stocks."
  spec.homepage = "https://github.com/dnutiu/smartbill-sdk-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .rubocop.yml .idea/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "base64", "~> 0.2"
  spec.add_dependency "dry-inflector", "~> 1.0"
  spec.add_dependency "dry-struct", "~> 1.6"
  spec.add_dependency "dry-types", "~> 1.7"
  spec.add_dependency "dry-validation", "~> 1.10"
  spec.add_dependency "zeitwerk", "~> 2.6"

  # Development / test dependencies live in the Gemfile.

  # For more information and examples about making a new gem, check out our
  # guide at: https://guides.rubygems.org/make-your-own-gem/
end
