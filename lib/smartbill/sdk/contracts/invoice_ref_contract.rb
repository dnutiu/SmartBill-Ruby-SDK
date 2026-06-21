# frozen_string_literal: true

module Smartbill
  module Sdk
    module Contracts
      # Validation contract for {Models::InvoiceRef}.
      #
      # Ensures the document reference has non-blank +series_name+ and
      # +number+ (the struct already enforces presence; this adds the
      # "filled" semantic check).
      class InvoiceRefContract < Base
        params do
          required(:series_name).filled(:string)
          required(:number).filled(:string)
        end
      end
    end
  end
end
