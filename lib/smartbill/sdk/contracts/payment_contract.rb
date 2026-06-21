# frozen_string_literal: true

module Smartbill
  module Sdk
    module Contracts
      # Validation contract for {Models::Payment}.
      #
      # Validates +type+ against the SmartBill payment-type set, +value+
      # (positive when present), date format, and +precision+.
      class PaymentContract < Base
        # Allowed +type+ values (mirrors {Models::PaymentType}).
        PAYMENT_TYPES = [
          "Chitanta",
          "Bon",
          "Card",
          "Card online",
          "CEC",
          "Bilet ordin",
          "Ordin plata",
          "Mandat postal",
          "Extras de cont",
          "Ramburs",
          "Alta incasare"
        ].freeze

        params do
          required(:company_vat_code).filled(:string)
          optional(:issue_date).maybe(:string, format?: DATE_REGEX)
          optional(:value).maybe(:float, gt?: 0)
          optional(:type).maybe(:string, included_in?: PAYMENT_TYPES)
          optional(:precision).maybe(:integer, gteq?: 0)
          optional(:exchange_rate).maybe(:float, gt?: 0)
        end
      end
    end
  end
end
