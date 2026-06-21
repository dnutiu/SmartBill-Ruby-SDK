# frozen_string_literal: true

require "dry-inflector"

module Smartbill
  module Sdk
    # Typed request/response models for the SmartBill Cloud REST API.
    #
    # Each model is a {Models::Struct} (a `Dry::Struct` subclass) and lives
    # in its own file (e.g. `models/invoice.rb` defines `Invoice`),
    # autoloaded by Zeitwerk.
    module Models
      # Shared inflector for snake_case ⇄ camelCase key mapping.
      INFLECTOR = Dry::Inflector.new
    end
  end
end
