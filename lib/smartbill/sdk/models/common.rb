# frozen_string_literal: true

require_relative "base"

module Smartbill
  module Sdk
    module Models
      # Client data (+client+ / +clientMin+).
      class Client < Model
        field :name, required: true
        field :vat_code
        field :code
        field :address
        field :reg_com
        field :is_tax_payer
        field :contact
        field :phone
        field :city
        field :county
        field :country
        field :email
        field :bank
        field :iban
        field :save_to_db
      end

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

      # Reference to an existing document (series + number).
      #
      # Requests use +seriesName+, but the +GET /estimate/invoices+
      # response returns +series+. Both names are accepted on input;
      # serialization always emits +seriesName+.
      class InvoiceRef < Model
        field :series_name, required: true, input_keys: ["series"]
        field :number, required: true
      end

      # Payment-at-issuance block embedded in an {Invoice}.
      class InvoicePayment < Model
        field :value, required: true
        field :payment_series
        field :type, required: true
        field :is_cash
      end
    end
  end
end
