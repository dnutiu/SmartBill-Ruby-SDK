# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Warehouse details attached to a stock list entry.
      class StockWarehouse < Struct
        attribute :warehouse_name, Types::Strict::String.optional.default(nil)
        attribute :warehouse_type, Types::Strict::String.optional.default(nil)
      end
    end
  end
end
