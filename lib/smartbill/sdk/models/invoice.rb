# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Request body for +POST /invoice+ (emitere factura).
      #
      # The JSON is sent as a bare object (the SmartBill +invoice+ envelope
      # key is handled by the API itself for this endpoint).
      class Invoice < Struct
        attribute :company_vat_code, Types::Strict::String
        attribute :client, Client.optional.default(nil)
        attribute :is_draft, Types::Strict::Bool.optional.default(nil)
        attribute :issue_date, Types::Strict::String.optional.default(nil)
        attribute :series_name, Types::Strict::String.optional.default(nil)
        attribute :currency, Types::Strict::String.optional.default(nil)
        attribute :exchange_rate, Types::Coercible::Float.optional.default(nil)
        attribute :language, Types::Strict::String.optional.default(nil)
        attribute :precision, Types::Coercible::Integer.optional.default(nil)
        attribute :issuer_cnp, Types::Strict::String.optional.default(nil)
        attribute :issuer_name, Types::Strict::String.optional.default(nil)
        attribute :aviz, Types::Strict::String.optional.default(nil)
        attribute :due_date, Types::Strict::String.optional.default(nil)
        attribute :mentions, Types::Strict::String.optional.default(nil)
        attribute :observations, Types::Strict::String.optional.default(nil)
        attribute :delegate_auto, Types::Strict::String.optional.default(nil)
        attribute :delegate_identity_card, Types::Strict::String.optional.default(nil)
        attribute :delegate_name, Types::Strict::String.optional.default(nil)
        attribute :delivery_date, Types::Strict::String.optional.default(nil)
        attribute :payment_date, Types::Strict::String.optional.default(nil)
        attribute :use_stock, Types::Strict::Bool.optional.default(nil)
        attribute :use_estimate_details, Types::Strict::Bool.optional.default(nil)
        attribute :use_payment_tax, Types::Strict::Bool.optional.default(nil)
        attribute :payment_base, Types::Coercible::Float.optional.default(nil)
        attribute :colected_tax, Types::Coercible::Float.optional.default(nil)
        attribute :payment_total, Types::Coercible::Float.optional.default(nil)
        attribute :payment_url, Types::Strict::String.optional.default(nil)
        attribute :estimate, InvoiceRef.optional.default(nil)
        attribute :products, Types::Array.of(Product).default([].freeze)
        attribute :payment, InvoicePayment.optional.default(nil)
      end
    end
  end
end
