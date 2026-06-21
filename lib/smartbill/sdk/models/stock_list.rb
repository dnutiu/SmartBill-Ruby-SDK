# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # A +list+ entry under the stocks response — products + warehouse.
      class StockList < Struct
        attribute :products, Types::Array.of(StockProduct).default([].freeze)
        attribute :warehouse, StockWarehouse.optional.default(nil)
      end
    end
  end
end
