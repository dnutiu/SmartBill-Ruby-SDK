# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Request body for +POST /invoice/reverse+ (stornare factura).
      #
      # Sent as a bare object (no envelope).
      class StornoRequest < Model
        field :company_vat_code, required: true
        field :series_name, required: true
        field :number, required: true
        field :issue_date
      end
    end
  end
end
