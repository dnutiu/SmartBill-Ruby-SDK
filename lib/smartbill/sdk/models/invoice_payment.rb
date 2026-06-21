# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Payment-at-issuance block embedded in an {Invoice}.
      class InvoicePayment < Struct
        attribute :value, Types::Coercible::Float
        attribute :payment_series, Types::Strict::String.optional.default(nil)
        attribute :type, Types::Strict::String
        attribute :is_cash, Types::Strict::Bool.optional.default(nil)
      end
    end
  end
end
