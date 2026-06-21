# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Request body for +POST /estimate+ (emitere proforma).
      class Estimate < Model
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
        field :delegate_name
        field :delegate_identity_card
        field :delegate_auto
        field :payment_url
        field :use_stock
        field :products, type: [Product], default: []
      end
    end
  end
end
