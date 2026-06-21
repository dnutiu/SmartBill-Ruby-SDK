# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # A product entry within a stock list.
      class StockProduct < Struct
        attribute :measuring_unit, Types::Strict::String.optional.default(nil)
        attribute :product_code, Types::Strict::String.optional.default(nil)
        attribute :product_name, Types::Strict::String.optional.default(nil)
        attribute :quantity, Types::Coercible::Float.optional.default(nil)
      end
    end
  end
end
