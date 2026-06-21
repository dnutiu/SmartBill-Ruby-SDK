# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
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
