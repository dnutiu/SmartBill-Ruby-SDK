# frozen_string_literal: true

module Smartbill
  module Sdk
    module Contracts
      # Validation contract for {Models::StornoRequest} (+POST /invoice/reverse+).
      class StornoContract < Base
        params do
          required(:company_vat_code).filled(:string)
          required(:series_name).filled(:string)
          required(:number).filled(:string)
          optional(:issue_date).maybe(:string, format?: DATE_REGEX)
        end
      end
    end
  end
end
