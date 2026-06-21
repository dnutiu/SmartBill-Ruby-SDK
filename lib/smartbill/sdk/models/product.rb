# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # A product or discount line on an invoice / proforma / bon fiscal.
      #
      # Discount-specific fields (+number_of_items+, +discount_type+,
      # +discount_percentage+, +discount_value+, +discount_tax_value+) are
      # only relevant when +is_discount+ is true.
      class Product < Model
        field :name, required: true
        field :code
        field :product_description
        field :translated_name
        field :translated_measuring_unit
        field :is_discount
        field :number_of_items
        field :measuring_unit_name
        field :currency
        field :quantity
        field :price
        field :is_tax_included
        field :tax_name
        field :tax_percentage
        field :exchange_rate
        field :save_to_db
        field :warehouse_name
        field :is_service
        # Discount fields
        field :discount_type
        field :discount_percentage
        field :discount_value
        field :discount_tax_value
      end
    end
  end
end
