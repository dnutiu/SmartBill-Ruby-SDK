# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Response for +GET /estimate/invoices+.
      class ProformaInvoicesResponse < BaseResponse
        field :are_invoices_created
        field :invoices, type: [InvoiceRef], default: []
      end
    end
  end
end
