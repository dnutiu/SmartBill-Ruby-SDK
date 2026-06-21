# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Response for +GET /invoice/paymentstatus+.
      class PaymentStatusResponse < Struct
        attribute :error_text, Types::Strict::String.optional.default(nil)
        attribute :message, Types::Strict::String.optional.default(nil)
        attribute :number, Types::Strict::String.optional.default(nil)
        attribute :series, Types::Strict::String.optional.default(nil)
        attribute :invoice_total_amount, Types::Coercible::Float.optional.default(nil)
        attribute :paid_amount, Types::Coercible::Float.optional.default(nil)
        attribute :unpaid_amount, Types::Coercible::Float.optional.default(nil)
        attribute :paid, Types::Strict::Bool.optional.default(nil)
      end
    end
  end
end
