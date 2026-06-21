# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Parsed response of +GET /tax+.
      class TaxesResponse < Struct
        attribute :error_text, Types::Strict::String.optional.default(nil)
        attribute :message, Types::Strict::String.optional.default(nil)
        attribute :taxes, Types::Array.of(Tax).default([].freeze)
      end
    end
  end
end
