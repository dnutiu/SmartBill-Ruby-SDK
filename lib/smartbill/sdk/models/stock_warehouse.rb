# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Warehouse details attached to a stock list entry.
      class StockWarehouse < Model
        field :warehouse_name
        field :warehouse_type
      end
    end
  end
end
