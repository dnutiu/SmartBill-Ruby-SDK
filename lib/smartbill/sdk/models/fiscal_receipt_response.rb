# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
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
