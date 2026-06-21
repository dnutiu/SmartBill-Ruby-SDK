# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Parsed response of +GET /stocks+.
      class StocksResponse < Struct
        attribute :error_text, Types::Strict::String.optional.default(nil)
        attribute :message, Types::Strict::String.optional.default(nil)
        attribute :list, Types::Array.of(StockList).default([].freeze)
      end
    end
  end
end
