# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # A +list+ entry under the stocks response — products + warehouse.
      class StockList < Model
        field :products, type: [StockProduct], default: []
        field :warehouse, type: StockWarehouse
      end
    end
  end
end
