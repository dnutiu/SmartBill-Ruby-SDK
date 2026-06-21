# frozen_string_literal: true

require_relative "base"
require_relative "common"

module Smartbill
  module Sdk
    module Models
      # Common envelope: +errorText+/+message+/+number+/+series+/+url+.
      class BaseResponse < Model
        field :error_text
        field :message
        field :number
        field :series
        field :url
      end

      # Response for invoice / proforma creation.
      class InvoiceCreateResponse < BaseResponse; end

      # Response for +POST /invoice/reverse+.
      class StornoResponse < BaseResponse
        field :document_url
        field :document_id
        field :document_view_url
      end

      # Response for +GET /invoice/paymentstatus+.
      class PaymentStatusResponse < Model
        field :error_text
        field :message
        field :number
        field :series
        field :invoice_total_amount
        field :paid_amount
        field :unpaid_amount
        field :paid
      end

      # Response for +GET /estimate/invoices+.
      class ProformaInvoicesResponse < BaseResponse
        field :are_invoices_created
        field :invoices, type: [InvoiceRef], default: []
      end

      # The +status+ block of an {EmailResponse}.
      class EmailStatus < Model
        field :code
        field :message
      end

      # Response for +POST /document/send+ (+Response.status+).
      class EmailResponse < Model
        field :status, type: EmailStatus
      end

      # Response for bon-fiscal endpoints.
      #
      # Used by +POST /payment+ when +type='Bon'+ (the response includes the
      # generated receipt id) and by +GET /payment/text+ (which returns the
      # base64-encoded fiscal-printer text in +message+).
      class FiscalReceiptResponse < BaseResponse
        field :id
      end
    end
  end
end
