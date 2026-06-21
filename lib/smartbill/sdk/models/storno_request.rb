# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Request body for +POST /invoice/reverse+ (stornare factura).
      #
      # Sent as a bare object (no envelope).
      class StornoRequest < Struct
        attribute :company_vat_code, Types::Strict::String
        attribute :series_name, Types::Strict::String
        attribute :number, Types::Strict::String
        attribute :issue_date, Types::Strict::String.optional.default(nil)
      end
    end
  end
end
