# frozen_string_literal: true

module Smartbill
  module Sdk
    module Contracts
      # Validation contract for {Models::Invoice}.
      #
      # Adds semantic rules on top of the struct's shape/coercion: date
      # fields must match +YYYY-MM-DD+, +precision+ must be a non-negative
      # integer, and the embedded +payment+ (when present) must satisfy the
      # {InvoicePaymentContract} rules.
      class InvoiceContract < Base
        params do
          required(:company_vat_code).filled(:string)
          optional(:issue_date).maybe(:string, format?: DATE_REGEX)
          optional(:due_date).maybe(:string, format?: DATE_REGEX)
          optional(:delivery_date).maybe(:string, format?: DATE_REGEX)
          optional(:payment_date).maybe(:string, format?: DATE_REGEX)
          optional(:precision).maybe(:integer, gteq?: 0)
          optional(:exchange_rate).maybe(:float, gt?: 0)
          optional(:payment).maybe(:hash) do
            required(:value).filled(:float, gt?: 0)
            required(:type).filled(:string)
          end
        end
      end
    end
  end
end
