# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # A product or discount line on an invoice / proforma / bon fiscal.
      #
      # Discount-specific fields (+number_of_items+, +discount_type+,
      # +discount_percentage+, +discount_value+, +discount_tax_value+) are
      # only relevant when +is_discount+ is true.
      class Product < Struct
        attribute :name, Types::Strict::String
        attribute :code, Types::Strict::String.optional.default(nil)
        attribute :product_description, Types::Strict::String.optional.default(nil)
        attribute :translated_name, Types::Strict::String.optional.default(nil)
        attribute :translated_measuring_unit, Types::Strict::String.optional.default(nil)
        attribute :is_discount, Types::Strict::Bool.optional.default(nil)
        attribute :number_of_items, Types::Coercible::Integer.optional.default(nil)
        attribute :measuring_unit_name, Types::Strict::String.optional.default(nil)
        attribute :currency, Types::Strict::String.optional.default(nil)
        attribute :quantity, Types::Coercible::Float.optional.default(nil)
        attribute :price, Types::Coercible::Float.optional.default(nil)
        attribute :is_tax_included, Types::Strict::Bool.optional.default(nil)
        attribute :tax_name, Types::Strict::String.optional.default(nil)
        attribute :tax_percentage, Types::Coercible::Float.optional.default(nil)
        attribute :exchange_rate, Types::Coercible::Float.optional.default(nil)
        attribute :save_to_db, Types::Strict::Bool.optional.default(nil)
        attribute :warehouse_name, Types::Strict::String.optional.default(nil)
        attribute :is_service, Types::Strict::Bool.optional.default(nil)
        # Discount fields
        attribute :discount_type, Types::Coercible::Integer.optional.default(nil)
        attribute :discount_percentage, Types::Coercible::Float.optional.default(nil)
        attribute :discount_value, Types::Coercible::Float.optional.default(nil)
        attribute :discount_tax_value, Types::Coercible::Float.optional.default(nil)
      end
    end
  end
end
