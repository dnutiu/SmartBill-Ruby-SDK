# frozen_string_literal: true

module Smartbill
  module Sdk
    module Contracts
      # Validation contract for {Models::EmailDocument} (+POST /document/send+).
      #
      # Validates +type+ (factura / proforma) and a basic shape check on the
      # recipient addresses. +subject+ and +body_text+ must be Base64-encoded
      # by the caller — this contract does not verify the encoding.
      class EmailContract < Base
        DOCUMENT_TYPES = %w[factura proforma].freeze
        # Very permissive e-mail shape check — the SmartBill API does the
        # authoritative validation.
        EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/

        params do
          required(:company_vat_code).filled(:string)
          required(:series_name).filled(:string)
          required(:number).filled(:string)
          optional(:type).maybe(:string, included_in?: DOCUMENT_TYPES)
          optional(:to).maybe(:string, format?: EMAIL_REGEX)
          optional(:cc).maybe(:string, format?: EMAIL_REGEX)
          optional(:bcc).maybe(:string, format?: EMAIL_REGEX)
        end
      end
    end
  end
end
