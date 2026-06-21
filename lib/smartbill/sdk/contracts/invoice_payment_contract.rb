# frozen_string_literal: true

module Smartbill
  module Sdk
    module Contracts
      # Validation contract for {Models::InvoicePayment} (payment at
      # issuance, embedded in an {Models::Invoice}).
      class InvoicePaymentContract < Base
        params do
          required(:value).filled(:float, gt?: 0)
          optional(:payment_series).maybe(:string)
          required(:type).filled(:string)
          optional(:is_cash).maybe(:bool)
        end
      end
    end
  end
end
