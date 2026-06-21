# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Request body for +POST /invoice+ (emitere factura).
      #
      # The JSON is sent as a bare object (the SmartBill +invoice+ envelope
      # key is handled by the API itself for this endpoint).
      class Invoice < Model
        field :company_vat_code, required: true
        field :client, type: Client
        field :is_draft
        field :issue_date
        field :series_name
        field :currency
        field :exchange_rate
        field :language
        field :precision
        field :issuer_cnp
        field :issuer_name
        field :aviz
        field :due_date
        field :mentions
        field :observations
        field :delegate_auto
        field :delegate_identity_card
        field :delegate_name
        field :delivery_date
        field :payment_date
        field :use_stock
        field :use_estimate_details
        field :use_payment_tax
        field :payment_base
        field :colected_tax
        field :payment_total
        field :payment_url
        field :estimate, type: InvoiceRef
        field :products, type: [Product], default: []
        field :payment, type: InvoicePayment
      end
    end
  end
end
