# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Response for +GET /invoice/paymentstatus+.
      class PaymentStatusResponse < Model
        field :error_text
        field :message
        field :number
        field :series
        field :invoice_total_amount
        field :paid_amount
        field :unpaid_amount
        field :paid
      end
    end
  end
end
