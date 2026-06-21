# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Parsed response of +GET /stocks+.
      class StocksResponse < Model
        field :error_text
        field :message
        field :list, type: [StockList], default: []
      end
    end
  end
end
