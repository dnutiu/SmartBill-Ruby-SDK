# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Response for +GET /estimate/invoices+.
      class ProformaInvoicesResponse < BaseResponse
        attribute :are_invoices_created, Types::Strict::Bool.optional.default(nil)
        attribute :invoices, Types::Array.of(InvoiceRef).default([].freeze)
      end
    end
  end
end
