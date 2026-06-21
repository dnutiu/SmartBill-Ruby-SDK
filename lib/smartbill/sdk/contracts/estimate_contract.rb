# frozen_string_literal: true

module Smartbill
  module Sdk
    module Contracts
      # Validation contract for {Models::Estimate} (proforma).
      class EstimateContract < Base
        params do
          required(:company_vat_code).filled(:string)
          optional(:issue_date).maybe(:string, format?: DATE_REGEX)
          optional(:due_date).maybe(:string, format?: DATE_REGEX)
          optional(:precision).maybe(:integer, gteq?: 0)
          optional(:exchange_rate).maybe(:float, gt?: 0)
        end
      end
    end
  end
end
