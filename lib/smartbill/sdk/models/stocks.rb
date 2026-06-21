# frozen_string_literal: true

require_relative "base"

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

      # Warehouse details attached to a stock list entry.
      class StockWarehouse < Model
        field :warehouse_name
        field :warehouse_type
      end

      # A +list+ entry under the stocks response — products + warehouse.
      class StockList < Model
        field :products, type: [StockProduct], default: []
        field :warehouse, type: StockWarehouse
      end

      # Parsed response of +GET /stocks+.
      class StocksResponse < Model
        field :error_text
        field :message
        field :list, type: [StockList], default: []
      end
    end
  end
end
