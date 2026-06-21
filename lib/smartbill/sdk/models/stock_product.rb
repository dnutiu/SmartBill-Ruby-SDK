# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # A product entry within a stock list.
      class StockProduct < Model
        field :measuring_unit
        field :product_code
        field :product_name
        field :quantity
      end
    end
  end
end
